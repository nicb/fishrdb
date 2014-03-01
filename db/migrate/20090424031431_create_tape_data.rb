#
# $Id: 20090424031431_create_tape_data.rb 405 2009-05-05 11:22:01Z nicb $
#
class CreateTapeData < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :tape_data, :force => true, :id => false do |t|

        t.integer   :tape_record_id, :null => false
        #
        #==================================================
        #
        # Data coming from the ScelsiDataBase.xls spreadsheet
        #
        # tag is mapped into the name field of the document
        #
        t.string    :inventory, :limit => 8
        t.string    :bb_inventory, :limit => 8
        t.string    :brand, :limit => 64
        t.string    :brand_evidence, :limit => 1
        t.float     :reel_diameter
        t.float     :tape_length_m
        t.string    :tape_material, :limit => 32
        t.string    :reel_material, :limit => 32
        t.string    :serial_number, :limit => 16
        t.string    :speed, :limit => 16
        t.string    :found, :limit => 4
        t.string    :recording_typology, :limit => 16
        t.string    :analog_transfer_machine, :limit => 32
        t.string    :plugins, :limit => 128
        t.string    :digital_transfer_software, :limit => 32
        t.string    :digital_file_format, :limit => 8
        t.integer   :digital_sampling_rate
        t.integer   :bit_depth
        t.date      :transfer_session_start
        t.date      :transfer_session_end
        #
        # notes go in the Document record container
        #
        #==================================================
        #
        # description goes into the Document record container
        #
        t.string    :transfer_session_location

	    end
      add_index :tape_data, :tape_record_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :tape_data
    end
  end
end
