#
# $Id: from_test.rb 538 2010-08-23 00:19:46Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class FromTest < ActiveSupport::TestCase

  def setup
    @values = [ 'class_A as cA', 'class_B', 'class_C as something_else' ]
    @key = :from
  end

  test "from option" do
    @values.each do
      |v|
      assert fo = FindOptionHelper::From.new(v)
      assert_equal "#{v}", fo.to_option_value
      assert_equal @key, fo.class.key
    end
  end

  test "from option group" do
    assert fog = FindOptionHelper::FromGroup.new
    @values.each { |v| assert fog << FindOptionHelper::From.new(v) }
    assert_equal({ @key => @values.join(', ') }, fog.to_option)
  end

end
