#
# $Id: duration_test.rb 596 2011-01-03 08:50:36Z nicb $
#

require 'test/test_helper'
require 'mp3_helper'

class DurationTest < ActiveSupport::TestCase

  include Mp3Helper::Split

  FIXTURE_FILES_PATH = File.join(File.dirname(__FILE__), 'fixtures')
  LOFI_TAPES_FILE_PATH = File.join(File.dirname(__FILE__), '..', '..', '..', 'public', 'private', 'lofi', '1', '0121-0140', 'NMGS0136-580', 'Audio Files')

  def setup
    assert @mp3_files = Dir.glob(File.join(LOFI_TAPES_FILE_PATH, '*.mp3'))
    assert @dur_is = '01:29:53.37'
  end

  def test_duration_from_mp3_file # requires mp3check
    @mp3_files.each do
      |mf|
      assert d = Mp3Helper::Duration.create_from_mp3_file(mf)
      assert_equal @dur_is, d.to_s, "File: #{mf}"
    end
  end

  def test_duration_from_mp3splt_string
    durs = { '139.12.126' => '02:19:12.12',
             '0.0.25' => '00:00:00.25',
             '56.59.99' => '00:56:59.99' }
    durs.each do
      |input, should_be|
      assert d = Mp3Helper::Duration.create_from_mp3splt_string(input)
      assert_equal should_be, d.to_s
    end
  end

  def test_addition
    durs = { '01:01:01.01' => '02:02:02.02',
             '00:32:00.00' => '01:04:00.00',
             '00:00:31.99' => '00:01:03.98',
           }
    durs.each do
      |input, should_be|
      assert d = Mp3Helper::Duration.create_from_mp3check_string(input)
      assert_equal should_be, (d + d).to_s
    end
  end

  def test_subtraction
    durs = { '01:01:01.01' => [ '00:30:00.00', '00:31:01.01' ],
             '00:32:00.00' => [ '00:16:00.00', '00:16:00.00' ],
             '00:00:31.99' => [ '00:00:15.99', '00:00:16.00' ],
           }
    durs.each do
      |input, values|
      assert should_be = values[1]
      assert op2 = Mp3Helper::Duration.create_from_mp3check_string(values[0])
      assert op1 = Mp3Helper::Duration.create_from_mp3check_string(input)
      assert_equal should_be, (op1 - op2).to_s
    end
  end

end
