#
# $Id: instrument_test.rb 517 2010-07-10 20:55:56Z nicb $
#
require 'test/test_helper'
require 'test/utilities/string'

class InstrumentTest < ActiveSupport::TestCase

  fixtures :users

  include Test::Utilities

  def setup
    assert @u = users(:staffbob)
    assert @c_args = { :creator_id => @u.id, :last_modifier_id => @u.id }
  end

  def test_create_and_destroy
    args = { :name => random_string }
    args.update(@c_args)
    assert i = Instrument.create(args)
    assert i.valid?
    assert i.destroy
    assert i.frozen?
  end

  def test_validations
    args = { :name => random_string }
    fargs = args.dup
    fargs.update(@c_args)
    assert i = Instrument.create
    assert !i.valid?
    assert i = Instrument.create(fargs)
    assert i.valid?
    assert i2 = Instrument.create(fargs)
    assert !i2.valid?
    dargs = fargs.dup
    dargs[:name] = dargs[:name].titleize.downcase
    assert i2 = Instrument.create(dargs)
    assert !i2.valid? # because it titleize the name
    assert i2 = Instrument.find_or_create(dargs, @c_args)
    assert i2.valid?
    assert_equal i, i2
  end
end
