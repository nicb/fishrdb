#
# $Id: tpw_test.rb 559 2010-11-23 20:51:22Z nicb $
#
require 'test/test_helper'
CWD = File.dirname(__FILE__)

require 'yaml'
require CWD + '/../tpw'

class TpwTest < ActiveSupport::TestCase

  def setup
    assert @filename = ENV['TPW_TEST_FILENAME'] || CWD + '/note.txt'
    @debug = false # sets lexing debug to verbose when true
  end

  test "compile" do
    assert tpw = Tdp::Tape::TapeParserWrapper.new(@filename, @debug)

    assert tape = tpw.compile

    File.open(CWD + '/' + tape.filename + '.yml', 'w') { |fy| YAML.dump(tape, fy) }
  end

end
