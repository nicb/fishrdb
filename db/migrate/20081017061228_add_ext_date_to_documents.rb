#
# $Id: 20081017061228_add_ext_date_to_documents.rb 270 2008-11-09 12:06:14Z nicb $
#
# this takes care only to the additions tied to the data_dal/data_al of series
# and folders
#
class AddExtDateToDocuments < ActiveRecord::Migration
  
  def self.up
    ActiveRecord::Base.transaction do
      add_column :documents, :data_dal_format, :string, :limit => 32, :null => false, :default => ''
      add_column :documents, :data_dal_input_parameters, :string, :limit => 3, :null => false, :default => '---'
      add_column :documents, :data_al_format, :string, :limit => 32, :null => false, :default => ''
      add_column :documents, :data_al_input_parameters, :string, :limit => 3, :null => false, :default => '---'
      add_column :documents, :senza_data, :string, :limit => 1, :null => false, :default => 'N'
      rename_column :documents, :data_visualizzata, :full_date_format
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
     remove_column :documents, :data_dal_format
     remove_column :documents, :data_dal_input_parameters
     remove_column :documents, :data_al_format
     remove_column :documents, :data_al_input_parameters
     remove_column :documents, :senza_data
     rename_column :documents, :full_date_format, :data_visualizzata
    end
  end

end
