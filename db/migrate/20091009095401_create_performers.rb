#
# $Id: 20091009095401_create_performers.rb 462 2009-10-12 01:07:40Z nicb $
#
class CreatePerformers < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :performers do |t|
	      t.integer :name_id, :null => false
	      t.integer :instrument_id, :null => false

        t.integer :creator_id, :null => false
        t.integer :last_modifier_id, :null => false
        t.timestamps
	    end
      add_index :performers, :name_id
      add_index :performers, :instrument_id
      add_index :performers, :creator_id
      add_index :performers, :last_modifier_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :performers
    end
  end
end
