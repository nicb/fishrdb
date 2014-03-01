#
# $Id$
#
class RecreateSidebarTree < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      drop_table :sidebar_trees
      create_table :sidebar_trees do |t|
        t.string  :session_id, :limit => 32, :null => false
        t.integer :selected_item_id, :null => true, :default => nil
      end
      add_index   :sidebar_trees, :session_id
      add_index   :sidebar_trees, :selected_item_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :sidebar_trees
      create_table :sidebar_trees, :id => false do |t|
        t.integer 'user_id', :null => false
        t.integer :selected_item_id, :null => true, :default => nil
        t.primary_key :user_id
      end
      add_index   'sidebar_trees', :user_id
    end
  end
end
