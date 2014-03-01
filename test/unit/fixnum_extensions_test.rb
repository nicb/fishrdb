#
# $Id: fixnum_extensions_test.rb 457 2009-10-05 08:14:24Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

require 'fixnum_extensions'

class FixnumExtensionsTest < ActiveSupport::TestCase

  def test_to_ssss
    size = 100
    0.upto(size-1) do
      n = (rand()*size*10).round
      n_compare = sprintf("%04d", n)
      assert_equal n_compare, n.to_ssss, "Forward comparison failed for number #{n}."
      assert_equal n, n.to_ssss.to_i, "Backward comparison failed for number #{n}."
    end
  end

  def test_reordering
    size = 100
    pool = []
    0.upto(size-1) do
      pool << (rand()*size*10).round
    end
    pool_s = pool.map { |n| sprintf("%04d", n) }
    assert_equal pool_s.sort, pool.map { |n| n.to_ssss }.sort
  end

end
