#
# $Id: data_aggregator_test.rb 596 2011-01-03 08:50:36Z nicb $
#
require 'test/test_helper'
require 'tdp/pro_tools/data_aggregator'

class DataAggregatorTest < ActiveSupport::TestCase

  FIXTURE_DATA_PATH = File.join(File.dirname(__FILE__), '..', '..', 'test')

  def setup
    assert @file0 = File.join(FIXTURE_DATA_PATH, 'NMGS0194-294.txt')
    assert @file1 = File.join(FIXTURE_DATA_PATH, 'NMGS0203-M102D.txt')
    assert @file2 = File.join(FIXTURE_DATA_PATH, 'NMGS0147-134.txt')
  end

  def test_data_aggregation
    [ @file0, @file1, @file2 ].each do
      |f|
      assert l = Tdp::ProTools::DataAggregator.new(f)
      assert !l.regions.blank?
      assert !l.tracks.blank?
      if ENV['PTS_DATA_AGGREGATOR_TEST_VERBOSE_PRINTOUT']
				l.tracks.values.each do
				  |t|
				  puts("====== #{File.basename(f)} #{t.name} ========\n")
				  t.regions.each do
				    |r|
				    printf("%-12s (%s) %s %s\n", r.name, r.source_file, r.source_start_time, r.source_end_time)
				  end
				end
      end
    end
  end

end
