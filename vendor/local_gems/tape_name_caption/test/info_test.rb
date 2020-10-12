#
# $Id: info_test.rb 555 2010-09-12 19:53:28Z nicb $
#

require 'test/test_helper'
require 'test/utilities'

require 'file_extensions'

class InfoTest < ActiveSupport::TestCase

  def setup
    @tape_filenames = read_tape_filenames
  end

  include TapeNameCaption::Constants

  test "info" do
    @tape_filenames.each do
      |tf|
      n = File.join(LOFI_TAPE_ROOT, tf)
      assert size_should_be = calc_mb(File.join(RAILS_ROOT, n))
      assert obj = TapeNameCaption::Caption.new(n)
      assert_equal size_should_be, obj.size
    end
  end

private

  include TapeNameCaption::Test::Utilities

  def calc_mb(filename)
    return sprintf("%.2f Mb", File.size(filename).to_f/1.megabyte.to_f)
  end

end
