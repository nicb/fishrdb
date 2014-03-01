#
# $Id: cd_record_test.rb 632 2013-07-12 14:45:53Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/document_subclass_test_case'
require File.dirname(__FILE__) + '/../utilities/multiple_test_runs'

class CdRecordTest < ActiveSupport::TestCase

  include DocumentSubclassTestCase
  include Test::Utilities::MultipleTestRuns

  number_of_runs(5)
# verbose(true)

  fixtures :documents, :names

  def setup
    special_args = {}
    set = configure(CdRecord, special_args, false) do
      |args, s, n|
      y = unique_random_year
      args.update(:cd_data => {
        :publishing_year => y,
        :record_label => self.class.random_string,
        :catalog_number => self.class.random_string,
      })
      ba_num = (rand()*10).round
      0.upto(ba_num) do
        |i|
        args[:cd_data].update('booklet_authors_' + i.to_s => { :first_name => self.class.random_string, :last_name => self.class.random_string, :disambiguation_tag => self.class.random_string, :creator_id => @u.id, :last_modifier_id => @u.id })
      end
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
      :timeasc => :publishing_year,
      :timedesc => :publishing_year,
      :location => :corda,
      :author => :sort_by_author, # default fallback
    }
    run_reorder_subtests(orders)
  end

  def test_cd_root
    assert cdr = CdRecord.cd_root
    assert cdr.valid?
    assert_equal Folder, cdr.class
    assert_equal 'CD e DVD', cdr.name
  end

	#
	# +test_sidebar_tip_functionality+: the +sidebar_tip+ method is critical
	# because if it breaks it blocks all displays and the application is
	# unusable. So we make triple sure that it works even with minimal
	# information
	#
	def test_sidebar_tip_functionality
		assert c = CdRecord.create_from_form(@default_args, @s_1)
		assert c.valid?
		assert str = c.sidebar_tip
		assert !str.empty?
	end

end
