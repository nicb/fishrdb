#
# $Id: segment_generation_test.rb 596 2011-01-03 08:50:36Z nicb $
#
require 'test/test_helper'
require 'test/extensions/subtest'
require 'bundle_generator'
require 'yaml'

class SegmentGenerationTest < ActiveSupport::TestCase

  include Test::Extensions

  FIXTURE_FILES_PATH = File.join(File.dirname(__FILE__), '..', '..', 'bundle_generator', 'test', 'fixtures')

  def setup
    assert @test_configs = ['NMGS0136-580', 'NMGS0147-134']
    assert @bundle_file = File.join(FIXTURE_FILES_PATH, 'good_tar_bundle.yml')
    File.open(@bundle_file, 'r') { |fh| assert @bundle_config = YAML.load(fh) }
    assert @configs = @bundle_config.keys.map { |k| { k => @bundle_config[k] } }
  end

  include FishrdbHelper::Lofi
  include Mp3Helper::Split

  attr_reader :source_path

  def test_real_mp3_split_named_segments_outfile_conversion # requires mp3splt
    process_configs('segment_container.tape_segments', 'start_region.source_file') do
	    |src, dest, ts|
	    assert generate_segment(src, dest, ts.start_region.source_start_time, ts.end_region.source_end_time, ts.segment_name)
    end
  end

  def test_real_mp3_split_time_segments_outfile_conversion # requires mp3splt
    process_configs('time_segments', 'source_file') do
	    |src, dest, ts|
	    assert generate_segment(src, dest, ts.start_time, ts.end_time, ts.segment_name)
    end
  end

private

  def process_configs(segs_method, sf_method)
    @configs.each do
      |c|
      test_tape = c.keys.first
      test_config = c.values.first
	    assert tape = BundleGenerator::Tape.new(test_tape, test_config)
      segments = eval("tape.#{segs_method}")
	    segments.each do
	      |ts|
	      assert srcfile = eval("ts.#{sf_method}")
        assert dest = '.'
	      assert @source_path = tape.segment_container.source_path
	      assert output_should_be = lofi_file_prefix(srcfile) + (("-%s" % [ ts.segment_name ])) + COMPRESS_FILE_SUFFIX
        yield(srcfile, dest, ts)
	      assert File.exists?(output_should_be), "File #{output_should_be} was not created"
	      assert File.unlink(output_should_be)
	      subtest_finished
	    end
    end
  end

  def clean_output_file(src, sname)
  end

end
