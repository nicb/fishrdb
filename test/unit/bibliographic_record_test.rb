#
# $Id: bibliographic_record_test.rb 632 2013-07-12 14:45:53Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/document_subclass_test_case'
require File.dirname(__FILE__) + '/../utilities/multiple_test_runs'

class BibliographicRecordTest < ActiveSupport::TestCase

  include DocumentSubclassTestCase
  include Test::Utilities::MultipleTestRuns

  number_of_runs(1)
# verbose(true)

  def setup
    special_args = { :data_dal => :time_arg }
    configure(BibliographicRecord, special_args) do
      |args, s, n|
      args.update(:bibliographic_data => { :author_last_name => "#{s}#{n}", :editor_last_name => "#{s}_ed_#{n}_ed" })
    end
    @default_args = { :name => "Test Title",
							:description_level_position => @dl.position, :creator => @u, :last_modifier => @u,
							:container_type => @ct}
  end

  def test_subtests
    run_subtests
  end

  def test_reorder
    orders =
    {
      :logic => :position,
      :alpha => :name,
      :timeasc => :data_dal,
      :timedesc => :data_dal,
      :location => :corda,
      :author => :sort_by_author,
    }
    run_reorder_subtests(orders)
  end

  def test_sidebar_name
    aln = "Author"
    afn = "The"
    eln = "Editor"
    efn = "The"
    #
    # first: author only
    #
    args = @default_args.dup
    args.update(:bibliographic_data => { :author_last_name => aln, :author_first_name => afn })
    assert br1 = BibliographicRecord.create_from_form(args, @s_1)
    assert_equal [aln, afn, args[:name]].conditional_join(', '), br1.sidebar_name
    #
    # second: editor only
    #
    args = @default_args.dup
    args.update(:bibliographic_data => { :editor_last_name => eln, :editor_first_name => efn })
    assert br2 = BibliographicRecord.create_from_form(args, @s_1)
    assert_equal [eln, efn, args[:name]].conditional_join(', '), br2.sidebar_name
    #
    # third: author and editor
    #
    args = @default_args.dup
    args.update(:bibliographic_data => { :author_last_name => aln, :author_first_name => afn,
                             :editor_last_name => eln, :editor_first_name => efn })
    assert br3 = BibliographicRecord.create_from_form(args, @s_1)
    assert_equal [aln, afn, args[:name]].conditional_join(', '), br3.sidebar_name
  end

  def test_reorder_by_author
    parent_args = @default_args.dup
    parent_args.update(:name => 'Parent')
    assert p = Folder.create_from_form(parent_args, @s_1)
    sort_cases = [[:author, :author], [:author, :editor], [:editor, :author], [:editor, :editor]]

    sort_cases.each do
      |pair|
      p0_ln_key = (pair[0].to_s + '_last_name').intern
      p0_fn_key = (pair[0].to_s + '_first_name').intern
      p1_ln_key = (pair[1].to_s + '_last_name').intern
      p1_fn_key = (pair[1].to_s + '_first_name').intern
	    c0_args = @default_args.dup
	    c0_args.update(:parent => p, :bibliographic_data => { p0_ln_key => 'BBB', p0_fn_key => 'YYY' })
	    c1_args = @default_args.dup
	    c1_args.update(:parent => p, :bibliographic_data => { p1_ln_key => 'AAA', p1_fn_key => 'ZZZ' })
	    assert c0 = BibliographicRecord.create_from_form(c0_args, @s_1)
	    assert c1 = BibliographicRecord.create_from_form(c1_args, @s_1)
      assert p.children.reload
	    assert p.reorder_children(:author)
	    assert_equal [c1, c0], p.children(true)
      assert c0.reload
      assert c1.reload
      assert c0.destroy
      assert c1.destroy
      assert p.children.reload
    end
  end

  def test_reorder_by_author_multikey
    parent_args = @default_args.dup
    parent_args.update(:name => 'Parent')
    assert p = Folder.create_from_form(parent_args, @s_1)
    sort_cases = [ [ { :volume => 2 }, { :volume => 1 } ],
						       [ { :publishing_date => { :month => 10, :day => 10, :year => 1980 }}, { :publishing_date => { :month => 1, :day => 1, :year => 1970 }} ],
						       [ { :publishing_date => { :month => 10, :year => 1980 }}, { :publishing_date => { :month => 1, :year => 1970 }} ],
						       [ { :publishing_date => { :year => 1980 }}, { :publishing_date => { :year => 1970 }} ],
								 ]
									 
    sort_cases.each do
      |pair|
			bd0_args = {}
			bd1_args = {}
			bd0_args.update(pair[0])
			bd1_args.update(pair[1])
	    c0_args = @default_args.dup
	    c0_args.update(:parent => p, :name => 'AAA', :bibliographic_data => bd0_args)
	    c1_args = @default_args.dup
	    c1_args.update(:parent => p, :name => 'AAA', :bibliographic_data => bd1_args)
	    assert c0 = BibliographicRecord.create_from_form(c0_args, @s_1)
	    assert c1 = BibliographicRecord.create_from_form(c1_args, @s_1)
      assert p.children.reload
	    assert p.reorder_children(:author)
	    assert_equal [c1, c0], p.children(true)
      assert c0.reload
      assert c1.reload
      assert c0.destroy
      assert c1.destroy
      assert p.children.reload
    end
  end

  def test_wrong_subkey_arguments
    args = @default_args.dup
    # put in a wrong date, so the creation will fail
    args.update(:bibliographic_data => { :publishing_date => { :year => 2009.to_s, :month => 2.to_s, :day => 31.to_s }}) 
    assert_nil c0 = nil
    assert_raise(ActiveRecord::RecordNotSaved) { c0 = BibliographicRecord.create_from_form(args, @s_1) }
    assert_nil c0
  end

	#
	# +test_sidebar_tip_functionality+: the +sidebar_tip+ method is critical
	# because if it breaks it blocks all displays and the application is
	# unusable. So we make triple sure that it works even with minimal
	# information
	#
	def test_sidebar_tip_functionality
		assert b = BibliographicRecord.create_from_form(@default_args, @s_1)
		assert b.valid?
		assert str = b.sidebar_tip
		assert !str.empty?
	end

end
