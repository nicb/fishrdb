#
# $Id: performer_test.rb 486 2010-04-04 21:33:39Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class PerformerTest < ActiveSupport::TestCase
  
  fixtures :sessions, :users, :names, :instruments

  def setup
    assert @u = users(:staffbob)
    assert @s_1 = sessions(:one)
    assert @name = Name.find_or_create(:last_name => self.class.random_string, :first_name => self.class.random_string, :disambiguation_tag => self.class.random_string, :creator_id => @u.id, :last_modifier_id => @u.id)
    assert @name2 = Name.find_or_create(:last_name => self.class.random_string, :first_name => self.class.random_string, :disambiguation_tag => self.class.random_string, :creator_id => @u.id, :last_modifier_id => @u.id)
    assert @instrument = Instrument.find_or_create(:name => self.class.random_string, :creator_id => @u.id, :last_modifier_id => @u.id)
  end

  def test_create_and_destroy
    assert p = Performer.create(:name => @name, :instrument => @instrument, :creator_id => @u, :last_modifier_id => @u)
    assert p.valid?

    assert p.destroy
    assert p.frozen?
    assert !@name.frozen?
    assert !@instrument.frozen?
  end

  def test_create_from_form
    args = {
      :name => { :last_name => @name.last_name, :first_name => @name.first_name, :disambiguation_tag => @name.disambiguation_tag, :creator_id => @u.id, :last_modifier_id => @u.id },
      :instrument => { :name => @instrument.name, :creator_id => @u.id, :last_modifier_id => @u.id },
      :creator_id => @u.id,
      :last_modifier_id => @u.id,
    }
    #
    # create with full args
    #
    assert p = Performer.create_from_form(args)
    assert p.valid?
    assert_equal @name, p.name
    assert_equal @instrument, p.instrument
    #
    # create w/o instrument
    #
    args2 = args.dup
    args2.delete(:instrument)
    args2.update(:name => { :last_name => @name2.last_name, :first_name => @name2.first_name, :disambiguation_tag => @name2.disambiguation_tag })
    assert p = Performer.create_from_form(args2)
    assert !p.valid?
    assert_equal @name2, p.name
    assert p.instrument = @instrument
    assert p.save
    assert p.valid?
    #
    # create w/o args (should not be valid but still execute correctly)
    #
    assert p = Performer.create_from_form
    assert !p.valid?
    #
    # substitute create arguments
    #
    args3 = args.dup
    args3.read_and_delete(:creator_id)
    args3.read_and_delete(:last_modifier_id)
    args3.update(:creator => @u, :last_modifier => @u)
    assert p = Performer.create_from_form(args3)
    assert p.valid?
  end

  class <<self
    include Test::Utilities
  end

end
