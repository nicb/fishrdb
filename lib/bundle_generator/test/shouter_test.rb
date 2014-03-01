#
# $Id: shouter_test.rb 572 2010-12-12 18:37:32Z nicb $
#

require 'tempfile'
require 'test/test_helper'

class ShouterTest < ActiveSupport::TestCase

  def test_say
    assert text = 'test 1 2 3'
    assert tmp = Tempfile.new('shouter_test')
    assert indent_value = 4
    File.open(tmp.path, 'w') do
      |fh|
      assert s = BundleGenerator::Shouter.new(fh, true, indent_value)
      assert s.say(text)
      assert s.say(text)
    end
    assert fh = tmp.open
    assert full_text = ((' ' * indent_value) + text)
    assert_equal full_text + full_text, fh.gets
    assert_nil tmp.close(true)
  end

  def test_say_with_newlines
    assert text = "test 1 2 3\n"
    assert tmp = Tempfile.new('shouter_test')
    assert indent_value = 8
    File.open(tmp.path, 'w') do
      |fh|
      assert s = BundleGenerator::Shouter.new(fh, true, indent_value)
      assert s.say(text)
      assert s.say(text)
    end
    assert fh = tmp.open
    assert full_text = ((' ' * indent_value) + text)
    assert_equal full_text, fh.gets
    assert_equal full_text, fh.gets
    assert_nil tmp.close(true)
  end

  def test_say_with_time
    assert before_msg = "starting..."
    assert after_msg = "done!"
    assert tmp = Tempfile.new('shouter_test')
    assert bmsg_iv = 8
    File.open(tmp.path, 'w') do
      |fh|
      assert s = BundleGenerator::Shouter.new(fh)
      assert s.say_with_time(after_msg, before_msg, bmsg_iv) { 1000 * 1000 }
    end
    assert fh = tmp.open
    assert almost_full_text = ((' ' * bmsg_iv) + before_msg + after_msg) + ' \('
    assert s = fh.gets
    assert s =~ /#{almost_full_text}/
    assert_nil tmp.close(true)
  end

end
