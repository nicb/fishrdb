#
# $Id: series_test.rb 541 2010-09-07 06:08:21Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/document_subclass_test_case'
require File.dirname(__FILE__) + '/../utilities/multiple_test_runs'

class SeriesTest < ActiveSupport::TestCase

  include DocumentSubclassTestCase
  include Test::Utilities::MultipleTestRuns

  number_of_runs(10)

  def setup
    special_args = { :data_dal => :time_arg }
    configure(Series, special_args)
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
      :author => :name, # default fallback
    }
    run_reorder_subtests(orders)
  end

end
