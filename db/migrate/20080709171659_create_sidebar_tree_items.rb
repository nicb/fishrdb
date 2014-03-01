#
# $Id: 20080709171659_create_sidebar_tree_items.rb 234 2008-07-14 06:54:57Z nicb $
#
class CreateSidebarTreeItems < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :sidebar_tree_items, :id => false do |t|
        t.integer 'sidebar_tree_user_id', :null => false
        t.integer 'document_id', :null => false
        t.enum    'status', :limit => [:open, :closed], :default => :closed, :null => false
        t.primary_key :sidebar_tree_user_id
      end
      add_index   'sidebar_tree_items', :sidebar_tree_user_id
      add_index   'sidebar_tree_items', :document_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :sidebar_tree_items
    end
  end
end
