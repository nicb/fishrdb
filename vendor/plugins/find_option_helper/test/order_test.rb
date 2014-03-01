#
# $Id: order_test.rb 538 2010-08-23 00:19:46Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class OrderTest < ActiveSupport::TestCase

  def setup
    @values = [ 'position', 'autore', 'time DESC' ]
    @key = :order
  end

  test "order option" do
    @values.each do
      |v|
      assert fo = FindOptionHelper::Order.new(v)
      assert_equal v, fo.to_option_value
      assert_equal @key, fo.class.key
    end
  end

  test "order option group" do
    assert fog = FindOptionHelper::OrderGroup.new
    @values.each { |v| assert fog << FindOptionHelper::Order.new(v) }
    osb = @values.join(', ')
    assert_equal({ @key => osb }, fog.to_option)
  end

end
