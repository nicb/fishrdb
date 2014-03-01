#
# $Id: 20100502085027_create_tape_box_marker_collections.rb 502 2010-05-30 20:56:50Z nicb $
#
class CreateTapeBoxMarkerCollections < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :tape_box_marker_collections do |t|
        t.string :location, :limit => 256, :null => false
        t.integer :tape_data_id, :null => false
	    end
      add_index :tape_box_marker_collections, :tape_data_id
    end
  end

  def self.down
    drop_table :tape_box_marker_collections
  end
end
