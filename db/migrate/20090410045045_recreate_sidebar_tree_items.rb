#
# $Id: 20090410045045_recreate_sidebar_tree_items.rb 362 2009-04-12 16:34:55Z nicb $
#
# This is needed to re-add a full fledged id into sidebar tree items
#
class RecreateSidebarTreeItems < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      drop_table :sidebar_tree_items
      create_table :sidebar_tree_items do |t|
        t.integer 'sidebar_tree_id', :null => false
        t.integer 'document_id', :null => false
        t.enum    'status', :limit => [:open, :closed], :default => :closed, :null => false
        t.string  'copied_to_clipboard', :limit => 4, :null => false, :default => 'no'
      end
      add_index   'sidebar_tree_items', :sidebar_tree_id
      add_index   'sidebar_tree_items', :document_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :sidebar_tree_items
      create_table :sidebar_tree_items, :id => false do |t|
        t.integer 'sidebar_tree_user_id', :null => false
        t.integer 'document_id', :null => false
        t.enum    'status', :limit => [:open, :closed], :default => :closed, :null => false
        t.string  'copied_to_clipboard', :limit => 4, :null => false, :default => 'no'
        t.primary_key :sidebar_tree_user_id
      end
      add_index   'sidebar_tree_items', :sidebar_tree_user_id
      add_index   'sidebar_tree_items', :document_id
    end
  end
end
