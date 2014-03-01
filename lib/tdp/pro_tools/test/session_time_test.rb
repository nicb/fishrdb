#
# $Id: session_time_test.rb 596 2011-01-03 08:50:36Z nicb $
#
require 'test/test_helper'
require 'test/extensions/subtest'
require 'tdp/pro_tools/session_time'
require 'bundle_generator/mp3splt_helper'
require 'bundle_generator/file_lookup_helper'

class SessionTimeTest < ActiveSupport::TestCase

  include Test::Extensions

  def setup
    @tapes = [ 'NMGS0194-294', 'NMGS0203-M102D', 'NMGS0136-580', 'NMGS0147-134' ]
  end

  def test_session_time_conversions
    process_regions(@tapes) do
      |l,t,r|
      [:source_start_time, :source_end_time].each do
        |time|
        assert stime = r.send(time).to_s.split(':')
        assert minutes = stime[0]
        assert seconds = stime[1].to_f
        assert input_should_be = "%02d.%05.2f" % [ minutes.to_i, seconds ]
        assert secs = seconds.floor
        assert frac = seconds - secs
        if frac > Tdp::ProTools::SessionTime::MIN_TIME_VALUE
          assert s_string = "%02ds_%02dh" % [ secs, (frac * 100).round ]
        else
          assert s_string = "%02ds" % [ secs ]
        end
        assert output_should_be = "%02dm_%s" % [ minutes.to_i, s_string ]
        assert_equal input_should_be, r.send(time).to_mp3splt
        assert_equal output_should_be, r.send(time).to_mp3splt_output_suffix
      end
    end
  end

  include BundleGenerator::FileLookupHelper
  include BundleGenerator::Mp3spltHelper

  attr_reader :source_path

  class BundleGenerator::Mp3spltHelper::SystemCallFailure < StandardError; end

  LOFI_PATH = File.join(File.dirname(__FILE__), '..', '..', '..', '..',
                        'public', 'private', 'lofi', '1', '0121-0140')

  def test_real_mp3splt_time_conversion # requires mp3splt
    process_regions(@tapes) do
      |l,t,r|
      assert st = r.source_start_time
      assert et = r.source_end_time
      assert srcfile = r.source_file
      assert @source_path = File.join(LOFI_PATH, File.basename(l.filename, '.txt'), 'Audio Files')
      assert output_should_be = mp3splt_output_filename(srcfile, '.', st, et)
      assert generate_segment(srcfile, '.', st, et)
      assert File.exists?(output_should_be), "File #{output_should_be} was not created (data is: #{st.to_s}, #{et.to_s})"
      # p st.to_s, et.to_s, output_should_be
      assert File.unlink(output_should_be)
      subtest_finished
    end
  end

private

  FIXTURE_DATA_GLOB_PFX = File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'public', 'private', 'session-notes', 'version-1', '*')

  def process_regions(tapes)
    tapes.each do
      |tape|
      assert path = Dir.glob(File.join(FIXTURE_DATA_GLOB_PFX, tape, tape + '.txt')).first
      assert l = Tdp::ProTools::DataAggregator.new(path)
      assert !l.regions.blank?
      assert !l.tracks.blank?
      l.tracks.values.each do
        |t|
        t.regions.each do
          |r|
          yield(l,t,r)
        end
      end
    end
  end

end

