#
# $Id: 20090826202113_create_names.rb 462 2009-10-12 01:07:40Z nicb $
#
# 
class CreateNames < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :names do |t|
        t.string :last_name, :limit => 1024
        t.string :first_name, :limit => 1024
        t.string :disambiguation_tag, :limit => 4096 # needed for homonyms

        t.integer :creator_id, :null => false
        t.integer :last_modifier_id, :null => false
        t.timestamps
	    end
      add_index :names, :creator_id
      add_index :names, :last_modifier_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :names
    end
  end
end
