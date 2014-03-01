#
# $Id: cd_data_test.rb 456 2009-10-04 05:04:32Z nicb $
#
require 'test/test_helper'

class CdDataTest < ActiveSupport::TestCase

  fixtures :users, :sessions, :container_types, :names

  def setup 
    assert @ct = container_types(:aa_busta)
    assert @dl = DescriptionLevel.unita_documentaria
    assert @u = users(:bootstrap)
    assert @publishing_year = Time.now.year - (rand()*10).floor
    assert @cd_args = { :creator => @u, :last_modifier => @u,
                     :container_type => @ct,
                     :description_level_position => @dl.position,
                     :name => 'Test CD',
                     :cd_data => { :record_label => 'Test label', :catalog_number => '001A',
                                   :publishing_year => @publishing_year,
                    },
                  }
    assert @names = Name.all
    assert !@names.empty?
    assert @s_1 = sessions(:one)
  end

  def test_create_and_destroy
    assert cd = CdRecord.create_from_form(@cd_args, @s_1)
    assert cd.valid?
    assert cd.cd_data.valid?

    cdd = cd.cd_data
    cd.destroy
    assert cd.frozen?
    assert_nil cdd.reload
  end

  def test_proxies
    assert cd = CdRecord.create_from_form(@cd_args, @s_1)
    [:record_label, :catalog_number, :publishing_year].each do
      |m|
      assert cd.respond_to?(m)
    end
  end

  def test_publishing_year
    assert cd = CdRecord.create_from_form(@cd_args, @s_1)
    assert_equal @publishing_year, cd.publishing_year.to_date.year
  end

  def test_validation_of_presence_of_cd_record_id
    #
    # this does not have the cd_record_id link set, so it should fail
    #
    assert cd_data = CdData.create(@cd_args[:cd_data])
    assert !cd_data.valid?
  end

  def test_associations
    CdParticipant.all.each { |nr| nr.destroy }
    assert_equal 0, CdParticipant.all.size
    assert cd = CdRecord.create_from_form(@cd_args, @s_1)
    assert_valid(cd)
    assert cdd = cd.cd_data
    assert_valid(cdd)
    #
    # test only authors on booklet_authors association
    #
    n_authors = @names.size
    c = 0
    @names.each do
      |a|
      assert cdd.booklet_authors << a
      c += 1
      assert_equal c, cdd.booklet_authors(true).size
      assert_equal a, cdd.booklet_authors.last
    end
    assert_equal @names, cdd.booklet_authors(true)
    assert_equal n_authors, cdd.booklet_authors(true).size
    assert cdd.booklet_authors.clear
    assert_equal 0, cdd.booklet_authors(true).size
    assert_equal 0, CdParticipant.all.size
    @names.each { |a| assert_valid(a) }
  end

  def test_date_update
    #
    # create a record first
    #
    parms = @cd_args.dup
    assert doc = CdRecord.create_from_form(parms, @s_1)
    assert_equal @publishing_year.to_s, doc.publishing_year.to_display
    #
    # update publishing_year
    #
    new_year = @publishing_year + 1
    parms = HashWithIndifferentAccess.new(:last_modifier => @u, :cd_data => { :publishing_year => new_year.to_s })
    assert doc = doc.update_from_form(parms)
    assert_equal new_year.to_s, doc.publishing_year.to_display
  end

end
