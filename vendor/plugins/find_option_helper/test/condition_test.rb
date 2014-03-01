#
# $Id: condition_test.rb 538 2010-08-23 00:19:46Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class ConditionTest < ActiveSupport::TestCase

  def setup
    @values =
    [
      { :cond => 'cond_1 =', :val => 1 }, 
      { :cond => 'cond_2 like', :val => '%2%' }, 
      { :cond => 'cond_3 not', :val => 'three' }, 
      { :cond => 'cond_without = value', :val => nil },
    ]
    @key = :conditions
  end

  test "condition option" do
    @values.each do
      |v|
      assert fo = FindOptionHelper::Condition.new(v[:cond], v[:val])
      if v[:val]
        assert ph = sprintf("val_%#x", fo.object_id).gsub(/\./,'').intern
        assert_equal "(#{v[:cond]} (:#{ph.to_s}))", fo.to_option_value
        assert_equal ph, fo.place_holder
        assert_equal({ fo.place_holder => v[:val] }, fo.value)
      else
        assert_equal "(#{v[:cond]})", fo.to_option_value
        assert_nil fo.value
      end
      assert_equal @key, fo.class.key
    end
  end

  test "condition option group" do
    assert fog = FindOptionHelper::ConditionGroup.new
    @values.each do
      |v|
      assert fo = FindOptionHelper::Condition.new(v[:cond], v[:val])
      assert fog << fo
    end
    assert_equal @key, fog.class.key
    ['and', 'or'].each do
      |jl|
      assert fog.join_logic = jl
      assert cond_should_be = "(#{fog.group.map { |co| co.cond_string }.join(" #{jl} ")})"
      assert vals_should_be = {}
      fog.group.map { |co| vals_should_be.update(co.value) if co.value }
      assert should_be = { fog.class.key => [cond_should_be, vals_should_be] }
      assert_equal should_be, fog.to_option
    end
  end

  test "adding multiple condition option groups" do
    assert one_more = FindOptionHelper::Condition.new('one_more like', 23)
    assert primary = FindOptionHelper::ConditionGroup.new
    assert sub = FindOptionHelper::ConditionGroup.new(' or ')
    @values.each do
      |v|
      assert sub << FindOptionHelper::Condition.new(v[:cond], v[:val])
    end
    assert primary << sub
    assert primary << one_more
    assert conds_should_be = "(((#{sub.group.map { |co| co.cond_string }.join(" #{sub.join_logic} ")})) #{primary.join_logic} #{one_more.cond_string})"
    assert vals_should_be = {}
    primary.group.map { |co| vals_should_be.update(co.value) if co.value }
    assert should_be = { primary.class.key => [conds_should_be, vals_should_be] }
    assert_equal should_be, primary.to_option
  end

end
