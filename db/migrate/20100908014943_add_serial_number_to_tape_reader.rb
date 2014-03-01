#
# $Id: 20100908014943_add_serial_number_to_tape_reader.rb 546 2010-09-08 22:44:40Z nicb $
#
class AddSerialNumberToTapeReader < ActiveRecord::Migration

  def self.up
    add_column :tape_data, :analog_transfer_machine_serial_number, :string, :limit => 1024
  end

  def self.down
    add_column :tape_data, :analog_transfer_machine_serial_number
  end

end
