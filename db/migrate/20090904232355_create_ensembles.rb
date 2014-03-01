#
# $Id: 20090904232355_create_ensembles.rb 462 2009-10-12 01:07:40Z nicb $
#
class CreateEnsembles < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :ensembles do |t|
        t.string :name, :limit => 4096, :null => false 
        t.integer :conductor_id

        t.integer :creator_id, :null => false
        t.integer :last_modifier_id, :null => false
        t.timestamps
      end
      add_index :ensembles, :conductor_id
      add_index :ensembles, :creator_id
      add_index :ensembles, :last_modifier_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :ensembles
    end
  end
end
