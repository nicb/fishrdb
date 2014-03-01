#
# $Id: authority_record_test.rb 616 2012-06-21 11:47:43Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class AuthorityRecordTest < ActiveSupport::TestCase

  #
  # fixture load order is important!
  #
	fixtures	:users, :documents, :cn_equivalents
  
  require File.dirname(__FILE__) + '/authority_record_test_object'

  def setup
    assert @user     = User.authenticate('staffbob', 'testtest')
    @test_objs =
    [
      TestObject.new(SiteName, { :name => 'Milano' }, { :name => 'Bela Milàn' }, @user),
      TestObject.new(PersonName, { :name => 'Schumacher', :first_name => 'Michael', :pseudonym => 'Schumi' }, { :name => "Paoli", :first_name => 'Gino' }, @user),
      TestObject.new(ScoreTitle, { :name => 'Ho' }, { :name => 'Hooooo' }, @user),
      TestObject.new(CollectiveName, { :name => 'Antidogma Musica', :date_start => '1979-01-13' }, { :name => 'Dogma Musica', :date_start => '1919-01-13', :date_end => '1978-01-13' }, @user),
    ]
    @extra_test_objs = 
    [
      TestObject.new(PersonName, { :first_name => 'Michael' }, { :first_name => 'Gino' }, @user),
      TestObject.new(PersonName, { :name => 'Schumacher' }, { :name => "Paoli" }, @user),
      TestObject.new(PersonName, { :pseudonym => 'Schumi' }, { :pseudonym => "Gipi" }, @user),
    ]
    @all_test_objs = @test_objs + @extra_test_objs

    @all_test_objs.each do
      |to|
      assert to.var = to.klass.create!(to.attrs)
      to.var.reload
      assert to.varvar = to.var.send(to.varmeth).create(to.varattrs)
    end

    assert @cn_equivalents = CnEquivalent.find(:all)
	end
	# Replace this with your real tests.
 	def test_validity
    @test_objs.each do
      |to|
      assert to.var.valid?
      assert to.varvar.valid?
    end
 	end
  def test_destroy
    @test_objs.each do
      |to|
      assert ar = to.klass.create(:name => "Test of #{to.klass}", :creator => @user, :last_modifier => @user)
      assert ar.send(to.varmeth).create(:name => "Variant of Test of #{to.klass}", :creator => @user, :last_modifier => @user)
      ar.reload
      ar.destroy
      assert !to.klass.find_by_id(ar.read_attribute('id'))
      assert ar.frozen?, "authority record is not frozen after destroy!  (#{ar.inspect})"
      assert ar.send(to.varmeth)[0].frozen?
    end
  end
	def test_methods
    @test_objs.each do
      |to|
      to.kmeths.each do
        |tokm|
        assert_equal to.var.send(tokm).to_s, to.attrs[tokm]
      end
    end
    #
    # test false positives
    #
    @test_objs.each do
      |to|
      unless to.klass == PersonName
        assert_nil to.var.first_name
      end
      unless to.klass == CollectiveName
        assert_nil to.var.date_start
        assert_nil to.var.date_start
      end
    end
	end
	def test_validations
		assert u = @user
		# it should not be possible to create a base class
		begin
			failed_create = AuthorityRecord.create(:name => "Aldous", :creator_id => u.id, :last_modifier_id => u.id)
		rescue NoMethodError # catch the exception from the call above
		end
		assert_nil failed_create
		assert_nil PersonName.create(:creator_id => u.id, :last_modifier_id => u.id).id
		#
		# should be possible to create a PersonName with either a last name, or a
		# first name, or a pseudonym
		#
		[:name, :first_name, :pseudonym].each do
			|attr|
			assert pn = PersonName.create(attr => "Test #{attr.to_s}", :creator_id => u.id, :last_modifier_id => u.id)
			assert pn.valid?
			pn.destroy
		end
		assert_not_nil PersonName.create(:name => "Paepius", :first_name => "Ginous", :creator_id => u.id, :last_modifier_id => u.id).id
		assert_not_nil PersonName.create(:name => "Paepius", :first_name => "Naepius", :creator_id => u.id, :last_modifier_id => u.id).id 
		assert_not_nil PersonName.create(:name => "Paepius", :first_name => "Naepius", :pseudonym => 'Test Pseudonym', :creator_id => u.id, :last_modifier_id => u.id).id 
		#
		# other ar validation
		#
		assert_nil SiteName.create(:name => nil, :creator_id => u.id, :last_modifier_id => u.id).id
		assert_nil ScoreTitle.create(:name => '', :creator_id => u.id, :last_modifier_id => u.id).id
	end
	#
	# testing variant records
	#
	def test_variants_validity
    @test_objs.each do
      |to|
      assert to.varvar.valid?
    end
	end
	def test_variants
    @test_objs.each do
      |to|
      assert_equal to.var.send(to.varmeth).size, 1, "Call #{to.var.class.name}(#{to.var.name}).#{to.varmeth.to_s}.size failed"
      assert_equal to.varvar.accepted_form.read_attribute('id'),
        to.var.read_attribute('id'),
        "Call #{to.var.class.name}(#{to.var.name}).#{to.refmeth.to_s}.id comparison with #{to.var.class.name}(#{to.var.read_attribute('id')} failed"
    end
	end
#
#!!! The next test won't work until the counter_cache situation is not fixed
#
#  def test_counter_cache
#    @test_objs.each do
#      |to|
#      assert_equal first_size = to.var.send(to.varmeth).size, to.var.children_count
#    end
#  end

  def test_matches
    @all_test_objs.each do
      |to|
      to.non_matchers.each do
        |nm|
        match_attrs = {}
        to.kmeths.each { |k| match_attrs[k] = to.attrs[k] }
        assert to.var.match?(match_attrs), "#{to.klass.name}.match?(#{match_attrs.inspect}) fails to match against its own attributes"
        assert !to.var.match?(to.non_matchers), "!#{to.klass.name}.match?(#{to.non_matchers.inspect}) fails"
        to.kmeths.each { |k| match_attrs[k] = to.varattrs[k] }
        assert to.varvar.match?(match_attrs), "#{to.varklass.name}.match?(#{match_attrs.inspect}) fails to match against its own attributes"
        assert !to.varvar.match?(to.non_matchers), "!#{to.varklass.name}.match?(#{to.non_matchers.inspect}) fails"
        #
        # person names require some extra testing for half empty attributes
        #
        if to.klass == PersonName
          if to.kmeths.size == 1
            if to.kmeths[0] == :name
              match_attrs = to.attrs.dup
              match_attrs[:first_name] = 'Enio'
              assert !to.var.match?(match_attrs), "#{to.klass.name}.match?(#{match_attrs.inspect}) matches against its own botched attributes"
              match_attrs.clear
              match_attrs = to.varattrs.dup
              match_attrs[:first_name] = 'Pilu'
              assert !to.varvar.match?(match_attrs), "#{to.varklass.name}.match?(#{match_attrs.inspect}) matches against its own botched attributes"
            elsif to.kmeths[0] = :first_name
              match_attrs = to.attrs.dup
              match_attrs[:name] = 'Jeffen'
              assert !to.var.match?(match_attrs), "#{to.klass.name}.match?(#{match_attrs.inspect}) matches against its own botched attributes"
              match_attrs.clear
              match_attrs = to.varattrs.dup
              match_attrs[:name] = 'Kangoo'
              assert !to.varvar.match?(match_attrs), "#{to.varklass.name}.match?(#{match_attrs.inspect}) matches against its own botched attributes"
            end
          else
            ['', 'var'].each do
              |vartype|
              myattrs = vartype + 'attrs'
              myvar = vartype + 'var'
              myclass = vartype + 'klass'
              [:name, :first_name].each do
                |sym|
                match_attrs = to.send(myattrs).dup
                match_attrs.delete(sym)
                assert !to.send(myvar).match?(match_attrs), "#{to.send(myclass).name}.match?(#{match_attrs.inspect}) matches against its own botched attributes"
                match_attrs.clear
              end
            end
          end
        end
      end
    end
  end

  def test_destroy_authority_record_linked_to_documents
    assert doc = Document.find_by_name('Partiture Giacinto Scelsi')
    @test_objs.each do
      |to|
      meth = "#{to.refmeth.pluralize}"
      sz = doc.send(meth).size
      params = to.attrs.dup
      params.delete(:creator)
      params.delete(:last_modifier)
      assert doc.send("create_#{to.refmeth}_record", @user, params)
      doc.reload
      assert_equal doc.send(meth).size, sz+1, "#{doc.class.name}(#{doc.name[0..10]}...).#{meth} expected #{sz+1} but got #{doc.send(meth).size} instead"
    end
    doc.reload
    doc.authority_record_collection.each do
      |arc|
      doc.send(arc.class.method).reload
      assert_equal arc.all_records.size, 1, "#{arc.class.arclass}(#{arc.number}) should have 1 document referenced but it has instead #{arc.all_records.size}"
      assert_equal doc.send(arc.class.method).size, 1, "#{doc.class.name}(#{doc.id},#{doc.name[0..10]}...) should have 1 authority record referenced but it has instead #{doc.send(arc.class.method).size}"
    end
    doc.reload
    @test_objs.each do
      |to|
      to.var.reload
      assert_equal to.var.documents.size, 1, "#{to.klass.name}(#{to.var.name}) should have 1 document referenced but it has instead #{to.var.documents.size}"
    end
    @test_objs.each do
      |to|
      assert to.var.destroy
      assert to.var.frozen?
    end
    doc.reload
    doc.authority_record_collection.each do
      |arc|
      assert_equal doc.send(arc.class.method).size, 0
    end
  end

  def test_one_destroy_among_many_ars
    assert doc = Document.find_by_name('Partiture Giacinto Scelsi')
    num_ars = 3
    @test_objs.each do
      |to|
      meth = "#{to.refmeth.pluralize}"
      sz = doc.send(meth).size
      params = to.attrs.dup
      params.delete(:creator)
      params.delete(:last_modifier)
      1.upto(num_ars) do
        |i|
        params[:name] = params[:name] + ' #{i}'
        assert doc.send("create_#{to.refmeth}_record", @user, params)
        doc.reload
        assert_equal doc.send(meth).size, sz+i, "#{doc.class.name}(#{doc.name[0..10]}...).#{meth} expected #{sz+i} but got #{doc.send(meth).size} instead"
      end
    end
    doc.reload
    @test_objs.each do
      |to|
      meth = "#{to.refmeth.pluralize}"
      assert (sz = doc.send(meth).size) > 0
      doc.send(meth).each do
        |ar|
        bsz = doc.send(meth).size
        assert ar.destroy
        doc.reload
        assert_equal doc.send(meth).size, bsz-1, "doc.#{meth}.size = #{doc.send(meth).size} after deleting a single AR! (should have been #{bsz-1})"
      end
    end
  end

  def test_author_transcriber_and_lyricist_fields
      pns = [
        TestObject.new(ScoreTitle, { :name => 'Un Nuovo Khoom' }, { :name => 'Cumme!' }, @user),
        TestObject.new(PersonName, { :name => 'Author', :first_name => 'I Am The' }, { :name => 'Author', :first_name => 'Gino' }, @user),
        TestObject.new(PersonName, { :name => 'Transcriber', :first_name => 'I Am The' }, { :name => 'Transcriber', :first_name => 'Gino' }, @user),
        TestObject.new(PersonName, { :name => 'Lyricist', :first_name => 'I Am The' }, { :name => 'Lyricist', :first_name => 'Gino' }, @user),
      ]
      pns.each do
        |to|
        assert to.var = to.klass.create!(to.attrs)
        to.var.reload
        assert to.varvar = to.var.send(to.varmeth).create(to.varattrs)
      end
      score_ar = pns[0].var
      assert score_ar.update_attributes!(:author => pns[1].var,
                                         :transcriber => pns[2].var,
                                         :lyricist => pns[3].var)
      assert score_ar.author === pns[1].var
      assert score_ar.transcriber === pns[2].var
      assert score_ar.lyricist === pns[3].var
  end

  def test_autocomplete_display_and_parse
    #
    # this tests the parsing of autocomplete score_tile lines
    #
    assert st = ScoreTitle.create(:name => 'Hooo là! Another very very very long title like one of those',
                      :organico => "flauto a becco, cicerchia a pompa, corno di bruma e quant'altro",
                      :creator => @user, :last_modifier => @user)
    assert st.valid?
    assert display = st.autocomplete_display
    parsed_hash = ScoreTitle.autocomplete_parse(display)
    assert parsed_hash.has_key?(:id)
    assert_equal parsed_hash[:id], st.id
    fc = ScoreTitle.find_conditions({:name => display})
    assert found_st = ScoreTitle.find(:first, :conditions => fc)
    assert found_st === st
  end

  def test_person_name_uniqueness_validations
    ref_attrs = { :name => 'Lastname', :first_name => 'First N.',
                  :date_start => '01-01-1950', :date_end => '01-01-2000',
                  :creator => @user, :last_modifier => @user  }
    #
    # reference name
    #
    assert pn0 = PersonName.create(ref_attrs)
    assert pn0.valid?
    #
    # exactly the same should not pass
    #
    assert pn1 = PersonName.create(ref_attrs)
    assert !pn1.valid?
    assert pn1.errors.invalid?(:name)
    #
    # now let's test removing one attribute at a time
    # (all tests should pass)
    #
    # let's change the first name to avoid conflicting with pn0
    #
    ref_attrs[:first_name] = 'Second N.'
    [:first_name, :date_start, :date_end].each do
      |a|
      new_attrs = ref_attrs.dup
      new_attrs.delete(a)
      assert pn_new = PersonName.create(new_attrs)
      assert pn_new.valid?
      assert pn_new.destroy
    end
    #
    # now let's *change* one attribute at a time
    # (all tests should pass)
    #
    new_attrs = ref_attrs.dup
    new_attrs[:first_name] += ' Extended'
    assert pn_new = PersonName.create(new_attrs)
    assert pn_new.valid?
    assert pn_new.destroy
    #
    new_attrs = ref_attrs.dup
    new_attrs[:date_start] = '02-01-1900'
    assert pn_new = PersonName.create(new_attrs)
    assert pn_new.valid?
    assert pn_new.destroy
    #
    new_attrs = ref_attrs.dup
    new_attrs[:date_end] = '02-01-2000'
    assert pn_new = PersonName.create(new_attrs)
    assert pn_new.valid?
    assert pn_new.destroy
  end

  def test_collective_name_uniqueness_validations
    ref_attrs = { :name => 'Collective Name', :cn_equivalent => @cn_equivalents[0],
                  :date_start => '01-01-1950', :date_end => '01-01-2000',
                  :creator => @user, :last_modifier => @user  }
    #
    # reference name
    #
    assert cn0 = CollectiveName.create(ref_attrs)
    assert cn0.valid?
    #
    # exactly the same should not pass
    #
    assert cn1 = CollectiveName.create(ref_attrs)
    assert !cn1.valid?
    assert cn1.errors.invalid?(:name)
    #
    # now let's test removing one attribute at a time
    # (all tests should pass)
    #
    [:date_start, :date_end].each do
      |a|
      new_attrs = ref_attrs.dup
      new_attrs.delete(a)
      assert cn_new = CollectiveName.create(new_attrs)
      assert cn_new.valid?
      assert cn_new.destroy
    end
    #
    # now let's *change* one attribute at a time
    # (all tests should pass)
    #
    new_attrs = ref_attrs.dup
    new_attrs[:date_start] = '02-01-1900'
    assert cn_new = CollectiveName.create(new_attrs)
    assert cn_new.valid?
    assert cn_new.destroy
    #
    new_attrs = ref_attrs.dup
    new_attrs[:date_end] = '02-01-2000'
    assert cn_new = CollectiveName.create(new_attrs)
    assert cn_new.valid?
    assert cn_new.destroy
  end

  def test_site_name_uniqueness_validation
    ref_attrs = { :name => 'Site Name',
                  :creator => @user, :last_modifier => @user  }
    #
    # reference name
    #
    assert sn0 = SiteName.create(ref_attrs)
    assert sn0.valid?
    #
    # exactly the same should not pass
    #
    assert sn1 = SiteName.create(ref_attrs)
    assert !sn1.valid?
    assert sn1.errors.invalid?(:name)
    #
    # a differnt name should pass
    #
    new_attrs = ref_attrs.dup
    new_attrs[:name] += ' Extended'
    assert sn_new = SiteName.create(new_attrs)
    assert sn_new.valid?
  end

  def test_score_title_uniqueness_validations
    author = PersonName.create(:name => 'Author', :creator => @user, :last_modifier => @user)
    transcriber = PersonName.create(:name => 'Transcriber', :creator => @user, :last_modifier => @user)
    lyricist = PersonName.create(:name => 'Lyricist', :creator => @user, :last_modifier => @user)
    #
    ref_attrs = { :name => 'This Piece', :organico => 'this organico',
                  :author => author, :transcriber => transcriber, :lyricist => lyricist,
                  :creator => @user, :last_modifier => @user  }
    #
    # reference name
    #
    assert st0 = ScoreTitle.create(ref_attrs)
    assert st0.valid?
    #
    # exactly the same should not pass
    #
    assert st1 = ScoreTitle.create(ref_attrs)
    assert !st1.valid?
    assert st1.errors.invalid?(:name)
    #
    # now let's test removing one attribute at a time
    # (all tests should pass)
    #
    [:organico, :author, :transcriber, :lyricist].each do
      |a|
      new_attrs = ref_attrs.dup
      new_attrs.delete(a)
      assert st_new = ScoreTitle.create(new_attrs)
      assert st_new.valid?
      assert st_new.destroy
    end
    #
    # now let's *change* one attribute at a time
    # (all tests should pass)
    #
    new_attrs = ref_attrs.dup
    new_attrs[:organico] += ' Extended'
    assert st_new = ScoreTitle.create(new_attrs)
    assert st_new.valid?
    assert st_new.destroy
    #
    new_author = PersonName.create(:name => 'New Author', :creator => @user, :last_modifier => @user)
    new_attrs = ref_attrs.dup
    new_attrs[:author] = new_author
    assert st_new = ScoreTitle.create(new_attrs)
    assert st_new.valid?
    assert st_new.destroy
    assert new_author.destroy
    #
    new_transcriber = PersonName.create(:name => 'New Transcriber', :creator => @user, :last_modifier => @user)
    new_attrs = ref_attrs.dup
    new_attrs[:transcriber] = new_transcriber
    assert st_new = ScoreTitle.create(new_attrs)
    assert st_new.valid?
    assert st_new.destroy
    assert new_transcriber.destroy
    #
    new_lyricist = PersonName.create(:name => 'New Lyricist', :creator => @user, :last_modifier => @user)
    new_attrs = ref_attrs.dup
    new_attrs[:lyricist] = new_lyricist
    assert st_new = ScoreTitle.create(new_attrs)
    assert st_new.valid?
    assert st_new.destroy
    assert new_lyricist.destroy
  end

  def test_person_name_dates
    assert pn = PersonName.create(:name => 'Date', :first_name => 'Tester', :creator => @user,
                           :last_modifier => @user, :date => ExtDate::Interval.new({:year => 1962},
                            {:day => 31, :month => 12, :year => 2001}, '--X', 'XXX', '%DD-%DA', '%Y', '%d/%m/%Y'))
    assert pn.valid?
    assert_equal '1962', pn.date_born
    assert_equal '31/12/2001', pn.date_died
    # reload from db
    assert pnn = PersonName.find(pn.read_attribute('id'))
    assert_equal '1962', pnn.date_born
    assert_equal '31/12/2001', pnn.date_died
    pn.destroy
    #
    # test empty dates
    #
    assert pn = PersonName.create(:name => 'Date', :first_name => 'Tester', :creator => @user,
                           :last_modifier => @user)
    assert pn.valid?
    assert_equal '', pn.date_born
    assert_equal '', pn.date_died
    pn.destroy
    #
    # test half-empty dates
    #
    assert pn = PersonName.create(:name => 'Date', :first_name => 'Tester', :creator => @user,
                           :last_modifier => @user, :date => ExtDate::Interval.new({:year => 1962},
                            {}, '%DD', '--X', '---', '%Y'))
    assert pn.valid?
    assert_equal '1962', pn.date_born
    assert_equal '', pn.date_died
    pn.destroy
    #
    # test updating attributes
    #
    assert pn = PersonName.create(:name => 'Date', :first_name => 'Tester', :creator => @user,
                           :last_modifier => @user)
    assert pn.valid?
    assert_equal '', pn.date_born
    assert_equal '', pn.date_died
    assert pn.update_attributes!(:date => ExtDate::Interval.new({:year => 1962 }, {}, '--X', '---', '%DD', '%Y'))
    assert pnn = PersonName.find(pn.read_attribute('id'))
    assert_equal '1962', pnn.date_born
    assert_equal '', pnn.date_died
    pn.destroy
    #
    # test updating attributes from form
    #
    #
    # test updating attributes
    #
    assert pn = PersonName.create_from_form(:name => 'Date', :first_name => 'Tester', :creator => @user,
                           :last_modifier => @user)
    assert pn.valid?
    assert_equal '', pn.date_born
    assert_equal '', pn.date_died
    assert pn.update_from_form("date_start_input_parameters"=>"--X",
                                 "date_start_format"=>"%Y", "date_end_format"=>"%d/%m/%Y",
                                 "full_date_format"=>"%DD-%DA", "date_end_input_parameters"=>"XXX",
                                 "date_start"=>{"month"=>"", "day"=>"", "year"=>"1963"},
                                 "date_end"=>{"month"=>"12", "day"=>"31", "year"=>"2002"})
    assert pnn = PersonName.find(pn.read_attribute('id'))
    assert_equal '1963', pnn.date_born
    assert_equal '31/12/2002', pnn.date_died
    pn.destroy
  end

  def test_person_name_name_methods
    assert fn = 'Tester'
    assert ln = 'Name'
    assert pn0 = PersonName.create(:name => ln, :first_name => fn, :creator => @user, :last_modifier => @user)
    assert pn0.valid?
    assert_equal ln, pn0.name
    assert_equal fn, pn0.first_name
    assert_equal [fn, ln].join(' '), pn0.full_name
    assert_equal [ln, fn].join(' '), pn0.name_full
    assert_equal [ln, fn].join(', '), pn0.to_s
    #
    assert pn1 = PersonName.create(:first_name => fn, :creator => @user, :last_modifier => @user)
    assert pn1.valid?
    assert_equal fn, pn1.first_name
    assert_equal fn, pn1.full_name
    assert_equal fn, pn1.name_full
    assert_equal fn, pn1.to_s
    #
    assert pn2 = PersonName.create(:name => fn, :creator => @user, :last_modifier => @user)
    assert pn2.valid?
    assert_equal fn, pn2.name
    assert_equal fn, pn2.full_name
    assert_equal fn, pn2.name_full
    assert_equal fn, pn2.to_s
  end

end
