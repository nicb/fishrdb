#
# $Id: string_extensions_test.rb 614 2012-05-11 17:25:14Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

require 'string_extensions'

class StringExtensionsTest < ActiveSupport::TestCase

  def setup
    assert @s = "this is a string\nwith\nmany\nnewlines"
    assert @s_should_become = @s.gsub(/\n/, '<br />')
    assert @s_nonl = "this is a string with no newlines"
    assert @s_nonalpha = "This! is@!$%^ a string\nwith many non-ascii àèéìòù characters"
    assert @s_alpha = "This is a string with many non ascii àèéìòù characters"
    assert @s_asciionly = "aeiouàèéìòùbcdfghlmn"
  end

  def test_newlines_to_html_extension_copy
    assert_equal @s_should_become, @s.newlines_to_html
    assert_equal @s_nonl, @s_nonl.newlines_to_html
  end

  def test_newlines_to_html_extension_in_place
    assert @s.newlines_to_html!
    assert_equal @s_should_become, @s
    assert !@s_nonl.newlines_to_html! # this returns nil, like gsub! on failing greps
  end

  def test_cleanse_copy
    assert_equal @s_alpha, @s_nonalpha.cleanse
  end

  def test_cleanse_in_place
    s = @s_nonalpha.dup
    assert s.cleanse!
    assert_equal @s_alpha, s
    # this *DOES NOT* fail, because it replaces non-alpha chars with spaces
    # (which are non-alpha themselves)
    assert s.cleanse! 
    assert !@s_asciionly.cleanse!
  end

end
