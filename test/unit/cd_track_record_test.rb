#
# $Id: cd_track_record_test.rb 632 2013-07-12 14:45:53Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/document_subclass_test_case'
require File.dirname(__FILE__) + '/../utilities/multiple_test_runs'

class CdTrackRecordTest < ActiveSupport::TestCase

  include DocumentSubclassTestCase
  include Test::Utilities::MultipleTestRuns

  number_of_runs(5)

  fixtures :users

  def setup
    @user = users(:staffbob)
    @c_args = { :creator_id => @user.id, :last_modifier_id => @user.id }
    special_args = {}
    set = configure(CdTrackRecord, special_args, false) do
      |args, s, n|
      args.update(:cd_track => {
        :duration => { :hour => '0', :minute => '23', :second => '42' },
        :ordinal => 1
      })
    end
    set.each do
      |cdtr|
      name_pool = self.class.create_random_names(@user)
      name_pool.each do
        |n|
        assert instr = Instrument.find_or_create({ :name => self.class.random_string }, @c_args)
        assert instr.valid?
        assert p = Performer.find_or_create({ :name_id => n.id, :instrument_id => instr.id }, @c_args)
        assert p.valid?
        assert e = Ensemble.find_or_create({ :name => self.class.random_string , :conductor_id => n.id }, @c_args)
        assert e.valid?
        cdtr.authors << n
        cdtr.performers << p
        cdtr.ensembles << e
      end
      cdtr.reload
    end
    @default_args = { :name => "Test Title",
							:description_level_position => @dl.position, :creator => @user, :last_modifier => @user,
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
      :timeasc => :position,
      :timedesc => :position,
      :location => :position,
      :author => :sort_by_author,
    }
    run_reorder_subtests(orders)
  end

	#
	# +test_sidebar_tip_functionality+: the +sidebar_tip+ method is critical
	# because if it breaks it blocks all displays and the application is
	# unusable. So we make triple sure that it works even with minimal
	# information
	#
	def test_sidebar_tip_functionality
		assert ctr = CdTrackRecord.create_from_form(@default_args, @s_1)
		assert ctr.valid?
		assert str = ctr.sidebar_tip
		assert !str.empty?
	end

end
