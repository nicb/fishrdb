#
# $Id: ensemble_test.rb 486 2010-04-04 21:33:39Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class EnsembleTest < ActiveSupport::TestCase
  
  fixtures :sessions, :users, :names

  def setup
    assert @u = users(:staffbob)
    assert @s_1 = sessions(:one)
    assert @name = Name.find_or_create(:last_name => self.class.random_string, :first_name => self.class.random_string, :disambiguation_tag => self.class.random_string, :creator_id => @u.id, :last_modifier_id => @u.id)
  end

  def test_create_and_destroy
    assert e = Ensemble.create(:name => self.class.random_string, :conductor => @name, :creator_id => @u, :last_modifier_id => @u)
    assert e.valid?

    assert e.destroy
    assert e.frozen?
    assert !@name.frozen?
  end

  def test_create_from_form
    args = {
      :name => self.class.random_string,
      :conductor => { :last_name => @name.last_name, :first_name => @name.first_name, :disambiguation_tag => @name.disambiguation_tag, :creator_id => @u.id, :last_modifier_id => @u.id },
      :creator_id => @u.id,
      :last_modifier_id => @u.id,
    }
    #
    # create with full args
    #
    assert e = Ensemble.create_from_form(args)
    assert e.valid?
    assert_equal args[:name], e.name
    assert_equal @name, e.conductor
    #
    # create w/o conductor
    #
    args2 = args.dup
    args2.delete(:conductor)
    args2.update(:name => self.class.random_string)
    assert e = Ensemble.create_from_form(args2)
    assert e.valid?
    assert_equal args2[:name], e.name
    assert_nil e.conductor
    #
    # create w/o args (should not be valid but still execute correctly)
    #
    assert e = Ensemble.create_from_form
    assert !e.valid?
  end

  class <<self
    include Test::Utilities
  end

end
