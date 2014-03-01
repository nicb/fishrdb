#
# $Id: find_options_test.rb 538 2010-08-23 00:19:46Z nicb $
#
require 'test/test_helper'

class FindOptionsTest < ActiveSupport::TestCase

  def setup
    @cond_options = 
    [
      FindOptionHelper::Condition.new('cond_A =', 0),
      FindOptionHelper::Condition.new('cond_B =', 1),
      FindOptionHelper::Condition.new('cond_C =', 2),
      FindOptionHelper::Condition.new('cond_D =', 3),
      FindOptionHelper::Condition.new('this = that'),
    ]
    @alt_cond_options = 
    [
      FindOptionHelper::Condition.new('alt_cond_A =', 0),
      FindOptionHelper::Condition.new('alt_cond_B =', 1),
      FindOptionHelper::Condition.new('alt_cond_C =', 2),
    ]
    @join_options = [
      FindOptionHelper::Joins.new('class_A'),
    ]
    @order_options = [
      FindOptionHelper::Order.new('position'),
      FindOptionHelper::Order.new('autore_score'),
      FindOptionHelper::Order.new('time DESC'),
    ]
    @from_options = [
      FindOptionHelper::From.new('class_A as cA'),
      FindOptionHelper::From.new('class_Bs'),
      FindOptionHelper::From.new('class_C as cC'),
    ]
  end

  test "find options class" do
    assert fo = FindOptionHelper::FindOptions.new
  end

  test "to_options method (conditions)" do
    assert fo = create_find_options(@cond_options)
    conds_should_be = prepare_cond_options(@cond_options, fo[:conditions].join_logic)
    assert_equal({ @cond_options.first.class.key => conds_should_be }, fo.to_options)
  end

  test "to_options method (joins)" do
    assert fo = create_find_options(@join_options)
    join_option_should_be = prepare_find_options({ :joins => @join_options.first.to_option_value })
    assert_equal join_option_should_be, fo.to_options
  end

  test "to_options method (order)" do
    assert fo = create_find_options(@order_options)
    order_option_should_be = prepare_find_options({ :order => @order_options.map { |oo| oo.to_option_value }.join(', ') })
    assert_equal order_option_should_be, fo.to_options
  end

  test "to_options method (from)" do
    assert fo = create_find_options(@from_options)
    from_option_should_be = { :from => @from_options.map { |oo| oo.to_option_value }.join(', ') }
    assert_equal from_option_should_be, fo.to_options
  end

  test "to_options method (cumulative)" do
    assert all_options = concat_all_options(@cond_options, @join_options, @order_options, @from_options)
    assert fo = create_find_options(all_options)
    conds_should_be = prepare_cond_options(@cond_options, fo[:conditions].join_logic)
    find_options_should_be = prepare_find_options({ :conditions => conds_should_be,
                                                    :joins => @join_options.first.to_option_value,
                                                    :order => @order_options.map { |oo| oo.to_option_value }.join(', '),
                                                    :from => @from_options.map { |oo| oo.to_option_value }.join(', '), })
    assert_equal find_options_should_be.keys.map { |s| s.to_s }.sort.map { |k| [k, find_options_should_be[k.intern]] }, fo.to_options.keys.map { |ss| ss.to_s }.sort.map { |k2| [k2, fo.to_options[k2.intern]] }
  end

  test "to_options method (cumulative with nested conditions)" do
    assert sub = FindOptionHelper::ConditionGroup.new('or')
    @alt_cond_options.each { |co| sub << co }
    cond_options_sb = @cond_options.dup
    @cond_options << sub
    cond_options_sb << sub.to_condition
    assert all_options = concat_all_options(@cond_options, @join_options, @order_options, @from_options)
    assert fo = create_find_options(all_options)
    conds_should_be = prepare_cond_options(cond_options_sb, fo[:conditions].join_logic)
    find_options_should_be = prepare_find_options({ :conditions => conds_should_be,
                                                    :joins => @join_options.first.to_option_value,
                                                    :order => @order_options.map { |oo| oo.to_option_value }.join(', '),
                                                    :from => @from_options.map { |oo| oo.to_option_value }.join(', '), })
    assert_equal find_options_should_be.keys.map { |s| s.to_s }.sort.map { |k| [k, find_options_should_be[k.intern]] }, fo.to_options.keys.map { |ss| ss.to_s }.sort.map { |k2| [k2, fo.to_options[k2.intern]] }
  end

private

  def create_find_options(opts)
    result = FindOptionHelper::FindOptions.new
    opts.each { |op| result << op }
    return result
  end

  def prepare_cond_options(conds, jl)
    result = []
    result << prepare_cond_string(conds, jl)
    result << prepare_cond_vals(conds)
    return result
  end

  def prepare_cond_string(conds, jl)
    return '(' + conds.map { |cv| cv.cond_string }.join(" #{jl} ") + ')'
  end

  def prepare_cond_vals(conds)
    result = {}
    conds.map { |cv| result.update(cv.value) if cv.value }
    return result
  end

  def prepare_find_options(opts)
    result = {}
    opts.each { |k, v| result.update(k => v) }
    return result
  end

  def concat_all_options(*all_opts)
    result = []
    all_opts.each { |opts| result.concat(opts) }
    return result
  end

end
