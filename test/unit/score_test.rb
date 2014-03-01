#
# $Id: score_test.rb 632 2013-07-12 14:45:53Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/document_subclass_test_case'
require File.dirname(__FILE__) + '/../utilities/multiple_test_runs'

class ScoreTest < ActiveSupport::TestCase

  include DocumentSubclassTestCase
  include Test::Utilities::MultipleTestRuns

  number_of_runs(10)

  def setup
    special_args = { :anno_composizione_score => :time_arg, :autore_score => :string_arg }
    configure(Score, special_args)
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
      :timeasc => :anno_composizione_score,
      :timedesc => :anno_composizione_score,
      :location => :corda,
      :author => :autore_score,
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
		assert s = Score.create_from_form(@default_args, @s_1)
		assert s.valid?
		assert str = s.sidebar_tip
		assert !str.empty?
	end

end
