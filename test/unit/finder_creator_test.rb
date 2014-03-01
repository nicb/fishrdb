#
# $Id: finder_creator_test.rb 486 2010-04-04 21:33:39Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class FinderCreatorTest < ActiveSupport::TestCase

  #
  # we use the name class as a host to test the methods
  #
  fixtures :users, :names

  class <<self
    include Test::Utilities
  end

  def setup
    assert @u = users(:staffbob)
    assert @ref = names(:gs)
    assert @c_args = { :creator_id => @u.id, :last_modifier_id => @u.id }
  end

  def test_find_or_create_with_all_args
    assert n = Name.find_or_create({ :last_name => 'Scelsi', :first_name => 'Giacinto', :disambiguation_tag => 'the count himself' }, @c_args)
    assert n.valid?
    assert_equal @ref, n
    assert_equal @ref.id, n.id
  end

  def test_find_or_create_with_some_args
    assert n = Name.find_or_create({ :last_name => 'Scelsi' }, @c_args)
    assert n.valid?
    assert_equal @ref, n
    assert_equal @ref.id, n.id
  end

  def test_find_or_create_with_no_args
    assert_nil Name.find_or_create({}, @c_args)
  end

  def test_find_or_create_with_random_args
    0.upto(99) do
      pool = self.class.create_random_strings(3, 1)
      args = {}
      keys = [ :last_name, :first_name, :disambiguation_tag ]
      pool.each_with_index do
        |n, idx|
        args.update(keys[idx] => n)
      end
      assert n = Name.find_or_create(args, @c_args)
      assert n.valid?
      assert n2 = Name.find_or_create(args, @c_args)
      assert n2.valid?
      assert_equal n, n2
      assert_equal n.id, n2.id
    end
  end

  def test_find_or_create_with_blank_args
    args = { :last_name => '', :first_name => '', :disambiguation_tag => '' }
    assert_nil Name.find_or_create(args, @c_args)
  end

end
