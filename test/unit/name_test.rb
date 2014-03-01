#
# $Id: name_test.rb 486 2010-04-04 21:33:39Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class NameTest < ActiveSupport::TestCase

  class <<self
    include Test::Utilities
  end

  fixtures :users

  def setup
    @u = users(:staffbob)
  end

  def test_create_and_destroy
    assert n = Name.create(:first_name => self.class.random_string, :last_name => self.class.random_string,
                           :creator => @u, :last_modifier => @u)
    assert n.valid?
    assert n.is_a?(Name)
    assert n.destroy
    assert n.frozen?
  end

  def test_presence_of_validations
    validations = {
      :invalid => [
        {}, # empty args
        { :creator => @u },
        { :creator => @u, :last_modifier_id => @u },
        { :creator => @u, :last_modifier_id => @u, :disambiguation_tag => self.class.random_string },
      ],
      :valid => [
        { :creator => @u, :last_modifier_id => @u, :first_name => self.class.random_string },
        { :creator => @u, :last_modifier_id => @u, :last_name => self.class.random_string },
        { :creator => @u, :last_modifier_id => @u, :last_name => self.class.random_string, :first_name => self.class.random_string },
        { :creator => @u, :last_modifier_id => @u, :last_name => self.class.random_string, :first_name => self.class.random_string, :disambiguation_tag => self.class.random_string },
      ],
    }
    #
    # invalid creators
    #
    validations[:invalid].each do
      |args|
      assert n = Name.create(args)
      assert !n.valid?
    end
    #
    # valid creators
    #
    validations[:valid].each do
      |args|
      assert n = Name.create(args)
      assert n.valid?
    end
  end

  def test_uniqueness_validations
    args = { :first_name => self.class.random_string, :last_name => self.class.random_string, :disambiguation_tag => self.class.random_string, :creator => @u, :last_modifier => @u }
    assert n = Name.create(args)
    assert n.valid?
    #
    assert n2 = Name.create(args)
    assert !n2.valid? # cannot be an exact duplicate
    #
    # but if I change the disambiguation tag...
    #
    cargs = args.dup
    cargs.update(:disambiguation_tag => 'changed')
    assert n3 = Name.create(cargs)
    assert n3.valid? # ...it works
  end

  def test_full_name
    assert args = { :last_name => self.class.random_string, :first_name => self.class.random_string,
             :disambiguation_tag => self.class.random_string, :creator => @u, :last_modifier => @u }
    assert order = [:first_name, :last_name, :disambiguation_tag]
    while args.has_key?(:first_name)
      ref = []
      order.each do
        |k|
        ref << args[k]
      end
      ref_string = ref.join(' ')
      assert n = Name.create(args)
      assert n.valid?, "Name.new(#{args.inspect}) is not valid (#{n.errors.full_messages.join(', ')})"
      assert_equal ref_string, n.full_name
      assert_equal ref_string, n.to_s
      delkey = order.pop
      args.delete(delkey)
    end
  end

  def test_create_from_form
    assert args = { :last_name => self.class.random_string, :first_name => self.class.random_string,
             :disambiguation_tag => self.class.random_string, :creator => @u, :last_modifier => @u }
    assert n = Name.create_from_form(args)
    assert n.valid?
  end

end
