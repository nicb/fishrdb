#
# $Id: find_test.rb 538 2010-08-23 00:19:46Z nicb $
#
require 'test/test_helper'

class FindTest < ActiveSupport::TestCase

  def setup
    @values = [ 'class_A', 'class_B', 'class_C' ]
  end

  test "find option" do
    assert fo = FindOptionHelper::Find.new(@values.first)
    assert_equal @values.first.to_s, fo.value
    assert_equal @values.first, fo.to_option_value
  end

  test "find option group" do
    assert fog = FindOptionHelper::FindGroup.new
    @values.each do
      |v|
      assert fo = FindOptionHelper::Find.new(v)
      assert fog << fo
    end
    assert_raise(FindOptionHelper::PureVirtualMethodCalled) { fog.class.key }
    assert_equal @values, fog.group.map { |fo| fo.value }
    assert_equal @values, fog.group.map { |fo| fo.to_option_value }
    assert_raise(FindOptionHelper::PureVirtualMethodCalled) { fog.to_option }
  end

  class Whatever < FindOptionHelper::Find

    class <<self

      def key
        return :whatever
      end

    end

  end

  class WhateverGroup < FindOptionHelper::FindGroup; end

  class NotAdmitted < FindOptionHelper::Find

    class <<self
      def key
        return :not_admitted
      end
    end

  end

  test "strict class typing" do
    assert na = NotAdmitted.new(@values.first)
    assert fog = WhateverGroup.new
    assert_raise(FindOptionHelper::FindClassMismatch) { fog << na }
  end

end
