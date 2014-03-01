#
# $Id: display_test.rb 554 2010-09-12 16:48:50Z nicb $
#

require 'test/test_helper'
require 'test/utilities'

class DisplayTest < ActiveSupport::TestCase

  def setup
    @tape_filenames = read_tape_filenames
  end

  test "display" do
    File.open('tmp/master_display_list.txt', 'w') do
      |fh|
	    @tape_filenames.each do
	      |tf|
	      assert obj = TapeNameCaption::Caption.new(tf)
	      assert d = obj.display
	      fh.puts(d)
	    end
    end
  end

private

  include TapeNameCaption::Test::Utilities

end
