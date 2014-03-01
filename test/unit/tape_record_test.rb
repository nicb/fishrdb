#
# $Id: tape_record_test.rb 614 2012-05-11 17:25:14Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/document_subclass_test_case'
require File.dirname(__FILE__) + '/../utilities/multiple_test_runs'

class TapeRecordTest < ActiveSupport::TestCase

  include DocumentSubclassTestCase
  include Test::Utilities::MultipleTestRuns

  number_of_runs(5)

  fixtures :documents, :tape_data, :tape_box_marker_collections

  def setup
    special_args = {:data_dal => :time_arg }
    configure(TapeRecord, special_args) do
      |args, s, n|
      args.update(get_full_params)
    end
  end

  def test_subtests
    run_subtests
  end

  def test_reorder
    orders =
    {
      :logic => :position,
      :alpha => :name,
      :location => :corda,
      :author => :name,
    }
    run_reorder_subtests(orders)
  end

  #
  # NOTE: the DocumentSubclassTestCase defines a session variable and assigns
  # it to the @s_1 variable
  #
  def test_tag_to_name_mapping
    parms = get_full_params
    tag = parms[:tape_data][:tag].dup
    assert tr = TapeRecord.create_from_form(parms, @s_1)
    assert tr.valid?
    assert_equal tag, tr.name
  end

  def test_parameter_consistency
    parms = get_full_params
    tape_data = parms[:tape_data].dup
    tape_data[:transfer_session_start] = convert_to_date_object(tape_data[:transfer_session_start])
    tape_data[:transfer_session_end] = convert_to_date_object(tape_data[:transfer_session_end])
    tape_data.delete(:tag)
    assert tr = TapeRecord.create_from_form(parms, @s_1)
    assert tr.valid?
    tape_data.keys.each do
      |k|
      assert_equal tape_data[k], tr.tape_data.send(k)
    end
  end

  def test_inventory_number_creation
    parms = get_full_params
    (dummy, invnum) = parms[:tape_data][:tag].dup.split('-')
    assert tr = TapeRecord.create_from_form(parms, @s_1)
    assert tr.valid?
    assert_equal invnum, tr.tape_data.inventory
  end

  def test_proxy_methods
    parms = get_full_params
    tape_data = parms[:tape_data].dup
    tape_data.delete(:tag)
    assert tr = TapeRecord.create_from_form(parms, @s_1)
    assert tr.valid?
    tape_data.keys.each do
      |k|
      assert tr.respond_to?(k)
      assert_equal tr.tape_data.send(k), tr.send(k)
    end
  end

  def test_validations
    parms = get_full_params
    tr_invalidators = [:creator, :last_modifier, :container_type, :description_level_position]
    td_invalidators = [:tag]
    tr_invalidators.each do
      |inv|
      inv_parms = parms.dup
      inv_parms.delete(inv)
      assert_raise(ActiveRecord::RecordNotSaved) do
        tr = TapeRecord.create_from_form(inv_parms, @s_1)
      end
    end
    td_invalidators.each do
      |inv|
      inv_parms = parms.dup
      inv_parms[:tape_data].delete(inv)
      assert_raise(ActiveRecord::RecordNotSaved) do
        tr = TapeRecord.create_from_form(inv_parms, @s_1)
      end
    end
  end

  def test_creation_with_empty_parameters
    assert_raise(ActiveRecord::RecordNotSaved) do
      tr = TapeRecord.create_from_form({}, @s_1)
    end
    parms = get_full_params
    parms.delete(:tape_data)
    assert_raise(ActiveRecord::RecordNotSaved) do
      TapeRecord.create_from_form(parms, @s_1)
    end
  end

  def test_destroy_from_tape_root
    assert troot = TapeData.tape_root
    parms = get_full_params
    #
    # create intermediate directory if it's not there
    #
    dir_name = TapeData.deduced_parent_name(parms[:tape_data][:tag])
    parent = Folder.find_by_name(dir_name)
    unless parent and parent.valid?
      assert parent = Folder.create_from_form({ :parent => troot, :creator => parms[:creator], 
                                    :name => dir_name,
                                    :last_modifier => parms[:last_modifier],
                                    :container_type => parms[:container_type],
                                    :description_level_position => DescriptionLevel.sottoserie.position }, @s_1)
    end
    parms.update(:parent => parent)
    assert tr = TapeRecord.create_from_form(parms, @s_1)
    assert tr.valid?
    #
    # now destroy from the top
    #
    troot.reload
    troot.children(true).each { |c| c.delete_from_form }
    assert troot.valid?
    assert !troot.frozen?
    assert_equal 0, troot.children(true).size
  end

  def test_sound_collection
    assert tr = documents(:tape_record_01)
    assert tr.valid?
    assert sc = tr.sound_collection
    sc.each { |tnc| assert_equal TapeNameCaption::Caption, tnc.class }
  end

private

  def get_full_params
    result =
    {
      :description => 'Nastro di prova assai',
      :creator => @u,
      :last_modifier => @u,
      :container_type => @ct,
      :description_level_position => @dl.position,
      :tape_data =>
      {
        :tag => 'NMGS0001-082',
        :bb_inventory => '102D',
        :brand => 'Scotch 111',
        :brand_evidence => 'B',
        :reel_diameter => 18,
        :tape_length_m => 270,
        :tape_material => 'Acetato',
        :reel_material => 'Plastica',
        :serial_number => '414156',
        :speed => '9,5-19',
        :found => 'HEAD',
        :recording_typology => 'MO A/B',
        :analog_transfer_machine => 'Studer A807',
        :plugins => 'Time-Shift, Pitch-Shift',
        :digital_transfer_software => 'PROTOOLS 7.3.1',
        :digital_file_format => 'AIFF',
        :digital_sampling_rate => 96000,
        :bit_depth => 24,
        :transfer_session_start => '2009-04-03',
        :transfer_session_end => '2009-04-24',
        :transfer_session_location => 'Discoteca di Stato, Roma',
      },
    }
  end

  def convert_to_date_object(date_string)
    (y, m, d) = date_string.split('-')
    return Date.civil(y.to_i, m.to_i, d.to_i)
  end

end
