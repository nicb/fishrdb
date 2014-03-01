#
# $Id: joins_test.rb 538 2010-08-23 00:19:46Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class JoinsTest < ActiveSupport::TestCase

  def setup
    @values = [ 'class_A', 'class_B' ]
    @key = :joins
  end

  test "joins option" do
    @values.each do
      |v|
      assert fo = FindOptionHelper::Joins.new(v)
      assert_equal "#{v}".intern, fo.to_option_value
      assert_equal @key, fo.class.key
    end
  end

  test "joins option group" do
    assert fog = FindOptionHelper::JoinsGroup.new
    assert fog << FindOptionHelper::Joins.new(@values.first)
    assert_raise(FindOptionHelper::OnlyOneOptionAllowed) { fog << FindOptionHelper::Joins.new(@values[1]) }
    assert_equal({ @key => @values.first.intern }, fog.to_option)
  end

end
