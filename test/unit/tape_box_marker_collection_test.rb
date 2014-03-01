#
# $Id: tape_box_marker_collection_test.rb 614 2012-05-11 17:25:14Z nicb $
#
require 'test/test_helper'

class TapeBoxMarkerCollectionTest < ActiveSupport::TestCase

  fixtures :documents, :tape_data

  def setup
    @tr = tape_data(:tape_data_01).tape_record
    @args = { :location => 'test', :tape_data_id => @tr.tape_data.id }
  end

  def test_create_destroy
    assert tbmc = TapeBoxMarkerCollection.create(@args)
    assert tbmc.valid?
    assert_equal @args[:location], tbmc.location
    #
    assert tbmc.destroy
    assert tbmc.frozen?
  end

	def test_associations
    previous = @tr.tape_data.tape_box_marker_collections(true).size
    num = 10
    tbmcs = []
    0.upto(num-1) do
      |n|
      args = @args.dup
      args.update(:location => args[:location] + ' ' + n.to_s)
      assert tbmcs << TapeBoxMarkerCollection.create(args)
      assert tbmcs.last.valid?
    end
    assert @tr.reload
    assert_equal num + previous, @tr.tape_data.tape_box_marker_collections(true).size
    assert @tr.destroy
    assert @tr.frozen?
    assert @tr.tape_data.frozen?
    tbmcs.each do
      |tbmc|
      assert_raise(ActiveRecord::RecordNotFound) { tbmc.reload }
    end
  end

	def test_validations
    [:location, :tape_data_id].each do
      |key|
      args = @args.dup
      args.delete(key)
      assert tbmc = TapeBoxMarkerCollection.create(args)
      assert !tbmc.valid?
    end
  end

end
