#
# $Id: 20081105125957_add_ext_date_to_ars.rb 270 2008-11-09 12:06:14Z nicb $
#
class AddExtDateToArs < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :authority_records, :date_start_format, :string, :limit => 32, :null => false, :default => ''
      add_column :authority_records, :date_start_input_parameters, :string, :limit => 3, :null => false, :default => '---'
      add_column :authority_records, :date_end_format, :string, :limit => 32, :null => false, :default => ''
      add_column :authority_records, :date_end_input_parameters, :string, :limit => 3, :null => false, :default => '---'
      add_column :authority_records, :full_date_format, :string, :limit => 128, :null => false, :default => ''
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :authority_records, :date_start_format
      remove_column :authority_records, :date_start_input_parameters
      remove_column :authority_records, :date_end_format
      remove_column :authority_records, :date_end_input_parameters
      remove_column :authority_records, :full_date_format
    end
  end
end
