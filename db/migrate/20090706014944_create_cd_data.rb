#
# $Id: 20090706014944_create_cd_data.rb 432 2009-08-30 21:44:20Z nicb $
#
class CreateCdData < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.transaction do
	    create_table :cd_data, :force => true, :id => false do |t|
	      t.integer :cd_record_id, :null => false
	      t.string  :record_label
	      t.string  :catalog_number
	      t.date    :publishing_year_db_record, :default => nil
	    end
      add_index :cd_data, :cd_record_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :cd_data
    end
  end
end
