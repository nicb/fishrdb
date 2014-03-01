#
# $Id: bibliographic_data_test.rb 614 2012-05-11 17:25:14Z nicb $
#
require 'test/test_helper'

class BibliographicDataTest < ActiveSupport::TestCase

  fixtures :users, :sessions, :container_types

  def setup
    assert @u = User.authenticate('staffbob', 'testtest')
    assert @ct = ContainerType.find_by_container_type('Scatola')
    assert @dl = DescriptionLevel.unita_documentaria
    @pdate_hash = { :day => '14', :month => '8', :year => '1956' }
    @empty_pdate_hash = { :day => '', :month => '', :year => '' }
    @year_year = 1988
    @year = ExtDate::Year.new(@year_year)
    @pdate = ExtDate::Base.new(@pdate_hash, 'XXX', '%d/%m/%Y')
    assert @s_1 = sessions(:one)
  end

protected

  def create_bibliographic_record(parms)
    doc_parms = HashWithIndifferentAccess.new(
      :name => 'Titolo Bibliografico',
      :description_level_position => @dl.position,
      :container_type => @ct,
      :note => "Queste sono le note del record bibliografico",
      :creator => @u,
      :last_modifier => @u)
    doc_parms.update(parms) unless parms.nil?

    return BibliographicRecord.create_from_form(doc_parms, @s_1)
  end

  def create_with_full_params
    full_parms = HashWithIndifferentAccess.new(
      :bibliographic_data => 
      {
        :author_last_name   => 'Cognome',
        :author_first_name  => 'Nome',
        :journal            => 'Il Journal',
        :volume             => '3',
        :number             => '4',
        :volume_title       => 'Titolo del Volume',
        :issue_year         => @year_year.to_s,
        :address            => 'Cambridge',
        :publisher          => 'The Publisher',
        :publishing_date    => @pdate_hash,
        :academic_year      => '2008-2009',
        :translator_last_name => 'Cognome-Traduttore',
        :translator_first_name => 'Nome-Traduttore',
        :editor_last_name => 'Cognome-Curatore',
        :editor_first_name => 'Nome-Curatore',
        :language           => 'Genovese/Yiddish',
        :start_page         => '26',
        :end_page           => '43',
        :abstract           => "Questo è l'abstract del record bibliografico"
      }
    )
    return create_bibliographic_record(full_parms)
  end

  def create_with_empty_params
    empty_parms = { :bibliographic_data => {}}
    return create_bibliographic_record(empty_parms)
  end

  def create_with_nil_params
    nil_parms = nil
    return create_bibliographic_record(nil_parms)
  end

public

  def test_create_and_destroy
    [ :create_with_full_params,
      :create_with_empty_params,
      :create_with_nil_params ].each do
      |m|
      #
      # create with all parameters
      #
      assert br = send(m)
      assert br.valid?, "Error in creating the bibliographic record (#{m.to_s}): #{br.errors.full_messages.join(', ')}"
      assert br.bibliographic_data.valid?, "Error in creating the bibliographic data record (#{m.to_s}): #{br.bibliographic_data.errors.full_messages.join(', ')}"
      #
      # try destroying it and check
      #
      br.destroy
      assert br.frozen?
      assert br.bibliographic_data.frozen?
    end
  end

  def test_proxy
    assert br = create_with_full_params
    attrs = br.bibliographic_data.class.column_names
    attrs.each do
      |a|
      assert br.respond_to?(a), "Proxy test failed to respond to method '#{a}'"
      assert br.send(a), "Proxy test failed for method '#{a}'"
    end
  end

  def test_validation
    #
    # can't be created by itself
    #
    assert bd = BibliographicData.create
    assert !bd.valid?
  end

  def test_dates
    assert br = create_with_full_params
    assert_equal @year.to_display, br.issue_year.to_display
    assert_equal @pdate.to_display, br.publishing_date.to_display
  end

  def test_date_creation
    ref = @pdate.dup
    displayed_pdate = ref.to_display
    biblio = { :bibliographic_data => { :issue_year => @year, :publishing_date => @pdate }}
    assert doc = create_bibliographic_record(biblio)
    assert_equal @year.to_display, doc.issue_year.to_display
    assert_equal displayed_pdate, doc.publishing_date.to_display
    assert doc.destroy
    # 
    # test with incomplete dates
    #
    dh = { :day => @pdate.day, :month => @pdate.month, :year => @pdate.year }
    [:day, :month, :year].each do
      |el|
      dt = dh.dup
      dt[el] = ''
      ips = ExtDate::Base.date_hash_to_ip_string(dt)
      f = ExtDate::Base.default_date_format_from_hash(dt)
      ref = ExtDate::Base.new(dt, ips, f)
      displayed_pdate = ref.to_display
      biblio = { :bibliographic_data => { :publishing_date => ref }}
      assert doc = create_bibliographic_record(biblio)
      assert_equal displayed_pdate, doc.publishing_date.to_display
      assert doc.destroy
    end
  end

  def test_date_update
    #
    # create a record first
    #
    biblio = HashWithIndifferentAccess.new(
      :last_modifier => @u,
      :bibliographic_data => { :issue_year => @year_year.to_s, :publishing_date => @pdate_hash }
    )

    assert doc = create_bibliographic_record(biblio)
    assert_equal @year.to_display, doc.issue_year.to_display
    assert_equal @pdate.to_display, doc.publishing_date.to_display
    #
    # update issue_year and empty date
    #
    new_year = @year_year + 1
    biblio = HashWithIndifferentAccess.new(:last_modifier => @u, :bibliographic_data => { :issue_year => new_year.to_s, :publishing_date => @empty_pdate_hash })
    assert doc = doc.update_from_form(biblio)
    assert_equal new_year.to_s, doc.issue_year.to_display
    assert_equal '', doc.publishing_date.to_display
    #
    # update publishing_date
    #
    new_pdate_hash = HashWithIndifferentAccess.new(:day => (@pdate.day + 1).to_s, :month => (@pdate.month - 1).to_s, :year => (@pdate.year + 1).to_s )
    ref = ExtDate::Base.new(new_pdate_hash,  @pdate.input_parameters, @pdate.ed_format)
    displayed_pdate = ref.to_display
    biblio = HashWithIndifferentAccess.new({ :last_modifier => @u,
               :bibliographic_data => { :publishing_date => new_pdate_hash } })#, :publishing_date_input_parameters => @pdate.input_parameters, :publishing_date_format => @pdate.ed_format }}
    assert doc = doc.update_from_form(biblio)
    assert_equal new_year.to_s, doc.issue_year.to_display
    assert_equal ref.to_display, doc.publishing_date.to_display
  end

  def test_composed_of
    biblio = {}
    assert doc = create_bibliographic_record(biblio)
    assert doc.bibliographic_data.valid?
    doc.bibliographic_data.destroy
    bd = BibliographicData.create(:bibliographic_record => doc, :issue_year => ExtDate::Year.new(1988))
    bd.reload
    doc.reload
    assert_equal '1988', bd.issue_year.to_display
    assert_equal '1988', doc.issue_year.to_display
  end

end
