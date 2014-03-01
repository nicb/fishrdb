#
# $Id: hash_extensions_test.rb 470 2009-10-18 16:18:58Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class HashExtensionsTest < ActiveSupport::TestCase

  def setup
    @default_hash = HashWithIndifferentAccess.new
    97.upto(101) do
      |n|
      key = n.chr.intern
      val = "I am #{n.chr.capitalize}"
      @default_hash.update(key => val)
    end
  end

  def test_read_and_delete
    #
    # without result
    #
    assert hash = @default_hash
    assert test_hash = hash.dup
    assert_equal hash[:a], test_hash.read_and_delete(:a)
    assert !test_hash.has_key?(:a)
    #
    # with result but good key
    #
    result = 42
    assert_equal hash[:b], test_hash.read_and_delete(:b, result)
    assert !test_hash.has_key?(:b)
    #
    # with result but bad key
    #
    assert_equal result, test_hash.read_and_delete(:non_existing_key, result)
  end

  def test_read_and_delete_returning_empty_if_null
    #
    # without result
    #
    assert hash = @default_hash
    assert test_hash = hash.dup
    assert_equal hash[:a], test_hash.read_and_delete_returning_empty_if_null(:a)
    assert !test_hash.has_key?(:a)
    #
    # with result but good key
    #
    assert_equal hash[:b], test_hash.read_and_delete_returning_empty_if_null(:b)
    assert !test_hash.has_key?(:b)
    #
    # with result but bad key
    #
    assert_equal '', test_hash.read_and_delete_returning_empty_if_null(:non_existing_key)
  end

  def test_transfer_with_arrays
    assert h = @default_hash
    n_keys = (h.keys.size * 0.75).round
    assert n_keys >= 1, "Number of transferred keys is too small (#{n_keys})"
    t_keys = h.keys[size-n_keys-1..size-1]
    assert nh = h.transfer(t_keys)
    t_keys.each do
      |k|
      assert !h.has_key?(k)
      assert nh.has_key?(k)
    end
  end

  def test_transfer_with_symbols_or_strings
    assert h = @default_hash.dup
    assert nh = h.transfer(:a)
    assert !h.has_key?(:a)
    assert nh.has_key?(:a)
    #
    assert nh2 = h.transfer('b')
    assert !h.has_key?('b')
    assert nh2.has_key?('b')
  end

  def test_transfer_with_not_found_keys
    assert h = {}
    assert nh = h.transfer(@default_hash.keys)
    assert nh.blank?
  end

  def test_blank_values_method
    test_hashes = [
      [ { :a => '', :b => nil, :c => "" }, true ],
      [ { :a => 0, :b => nil, :c => "" }, false ],
      [ { :a => 'test', :b => nil, :c => "test" }, false ],
      [ { :a => 'test', :b => 0, :c => "test" }, false ],
    ]
    test_hashes.each do
      |a|
      h = a[0]
      t = a[1]
      assert_equal t, h.blank_values?
    end
  end

end
