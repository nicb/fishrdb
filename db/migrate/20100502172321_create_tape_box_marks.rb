#
# $Id: 20100502172321_create_tape_box_marks.rb 502 2010-05-30 20:56:50Z nicb $
#
class CreateTapeBoxMarks < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :tape_box_marks do |t|
        t.text  :text, :null => false
        t.string :marker, :null => false, :limit => 256
        t.string :modifiers, :limit => 256
        t.boolean :reliability, :null => false, :default => true
        t.string :css_style, :null => false, :default => '', :limit => 4096
        t.integer :name_id
        t.integer :tape_box_marker_collection_id, :null => false
	    end
      add_index :tape_box_marks, :name_id
      add_index :tape_box_marks, :tape_box_marker_collection_id
    end
  end

  def self.down
    drop_table :tape_box_marks
  end
end
