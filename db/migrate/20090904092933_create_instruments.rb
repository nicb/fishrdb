#
# $Id: 20090904092933_create_instruments.rb 462 2009-10-12 01:07:40Z nicb $
#
class CreateInstruments < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :instruments do |t|
        t.string :name, :limit => 4096, :null => false, :unique => true
        t.integer :cd_track_participant_id

        t.integer :creator_id, :null => false
        t.integer :last_modifier_id, :null => false
        t.timestamps
	    end
      add_index :instruments, :cd_track_participant_id
      add_index :instruments, :creator_id
      add_index :instruments, :last_modifier_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :instruments
    end
  end
end
