#
# $Id: parser_test.rb 552 2010-09-12 10:50:29Z nicb $
#

require 'test/test_helper'
require 'test/utilities'

class ParserTest < ActiveSupport::TestCase

  def setup
    @tape_filenames = read_tape_filenames
  end

  test "parse errors" do
    @tape_filenames.each do
      |tf|
      assert obj = TapeNameCaption::Caption.new(tf)
      #
      # if it malformed, let's check it out
      #
      Rails::logger.debug(">>>> Malformed tape filename \"#{obj.filename}\"") if obj.malformed?
    end
  end

  test "proper parsing" do
    total_count = 0
    count = 0
    @tape_filenames.each do
      |tf|
      assert obj = TapeNameCaption::Caption.new(tf)
      unless obj.malformed? # we skip this name if it is malformed
        TapeNameCaption::Parse::Map::REGEXP_MAP.each do
          |k, v|
          assert obj.send(k) =~ v[:regexp], "method :#{k} does not match /#{v[:regexp]}/"
        end
      else
        count += 1
      end
      total_count += 1
    end
    percent = sprintf("%.2f", (count.to_f / total_count.to_f) * 100.0)
    Rails::logger.debug(">>>> counted a total of #{count}/#{total_count} (#{percent} %) malformed tape filenames")
  end

private

  include TapeNameCaption::Test::Utilities

end
