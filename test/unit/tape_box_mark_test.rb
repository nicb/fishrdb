#
# $Id: tape_box_mark_test.rb 614 2012-05-11 17:25:14Z nicb $
#
require 'test/test_helper'
require 'test/extensions/subtest'

class TapeBoxMarkTest < ActiveSupport::TestCase

  fixtures :names, :documents, :tape_data, :tape_box_marker_collections

  include Test::Extensions

  def setup
    @gs = names(:gs)
    @td = tape_data(:tape_data_01)
    @tbmc = tape_box_marker_collections(:tbmc_if_01)
    @tr = @tbmc.tape_data.tape_record
    @args = { :tape_box_marker_collection => @tbmc,
              :text => "test\nwith newlines\n\nand blank lines",
              :marker => 'penna biro blu', :modifiers => 'sottolineato',
              :name => @gs, :reliability => false }
  end

  def test_create_destroy
    assert tbm = TapeBoxMark.create(@args)
    assert tbm.valid?
    [:text, :marker, :modifiers, :reliability].each do
      |key|
      assert_equal @args[key], tbm.send(key)
    end
    assert_equal @gs.last_name, tbm.name.last_name
    assert_equal @gs.first_name, tbm.name.first_name
    #
    assert tbm.destroy
    assert tbm.frozen?
  end

  def test_associations
    #
    # tape box marker collections association
    #
    num = 10
    tbms = []
    @tbmc.tape_box_marks.clear
    0.upto(num-1) do
      |n|
      args = @args.dup
      args.update(:text => args[:text] + ' ' + n.to_s)
      assert tbms << TapeBoxMark.create(args)
      assert tbms.last.valid?
    end
    assert @tr.reload
    assert_equal num, @tbmc.tape_box_marks(true).size
    assert @tr.destroy
    assert @tr.frozen?
    assert @tr.tape_data.frozen?
    tbms.each do
      |tbm|
      assert_raise(ActiveRecord::RecordNotFound) { tbm.reload }
    end
  end

  def test_validations
    [:text, :marker, :tape_box_marker_collection].each do
      |key|
      args = @args.dup
      args.delete(key)
      assert tbmc = TapeBoxMark.create(args)
      assert !tbmc.valid?
    end
  end

  def test_markers
    args = @args.dup
    args.delete(:modifiers)
    assert tbm = TapeBoxMark.create(args)
    assert tbm.valid?
    markers =
    [
      { :written => 'penna biro blu', :read => 'color: blue' },
      { :written => 'matita nera', :read => 'color: black' },
      { :written => 'feltro rosso', :read => 'color: red' },
      { :written => 'gesso verde', :read => 'color: green' },
      { :written => 'pastello bordeaux', :read => 'color: Crimson' },
      { :written => 'penna biro', :read => 'color: black' }, # no color should default to black
    ]
    markers.each do
      |m|
      assert tbm.marker = m[:written]
      assert tbm.save
      assert tbm.reload
      assert_equal 'style="' + m[:read] + ';"', tbm.css_style
      subtest_finished
    end
    #
    # now let's test with creation
    #
    args = @args.dup
    markers.each do
      |m|
      args.delete(:modifiers)
      args.update(:marker => m[:written])
      assert tbm = TapeBoxMark.create(args)
      assert tbm.valid?
      assert_equal 'style="' + m[:read] + ';"', tbm.css_style
      subtest_finished
    end
    #
    # now let's test with empty marker (should fail)
    #
    args = @args.dup
    args.delete(:modifiers)
    args.update(:marker => '')
    assert tbm = TapeBoxMark.create(args)
    assert !tbm.valid?
  end

  def test_modifiers
    modifiers =
    [
      { :written => 'sottolineato', :read => 'color: blue; text-decoration: underline' },
      { :written => 'cancellato', :read => 'color: blue; text-decoration: line-through' },
      { :written => 'sottolineato cancellato', :read => 'color: blue; text-decoration: underline line-through' },
      { :written => 'incorniciato', :read => 'border-style: solid; color: blue' },
      { :written => 'incorniciato sottolineato', :read => 'border-style: solid; color: blue; text-decoration: underline' },
      { :written => 'incorniciato cancellato', :read => 'border-style: solid; color: blue; text-decoration: line-through' },
      { :written => 'incorniciato cancellato sottolineato', :read => 'border-style: solid; color: blue; text-decoration: line-through underline' },
      { :written => nil, :read => 'color: blue'}, # should behave gracefully on nil values
    ]
    modifiers.each do
      |m|
      args = @args.dup
      args.delete(:modifiers)
      assert tbm = TapeBoxMark.create(args)
      assert tbm.valid?
      tbm.modifiers = m[:written]
      assert tbm.save
      assert tbm.reload
      should_be = 'style="' + m[:read] + ';"'
      assert_equal should_be, tbm.css_style
      subtest_finished
    end
    #
    # now let's test with creation
    #
    args = @args.dup
    modifiers.each do
      |m|
      args = @args.dup
      args.delete(:modifiers)
      args.update(:modifiers => m[:written])
      assert tbm = TapeBoxMark.create(args)
      assert tbm.valid?
      should_be = 'style="' + m[:read] + ';"'
      assert_equal should_be, tbm.css_style
      subtest_finished
    end
    #
    # now let's test with empty modifiers (should be valid)
    #
    args = @args.dup
    args.delete(:modifiers)
    assert tbm = TapeBoxMark.create(args)
    assert tbm.valid?
    assert_equal 'style="color: blue;"', tbm.css_style
  end

end
