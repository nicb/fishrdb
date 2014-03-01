#
# $Id: 20090410025802_recreate_clipboard_items.rb 362 2009-04-12 16:34:55Z nicb $
#
# This is needed to re-add a full fledged id into sidebar tree items
#
class RecreateClipboardItems < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      drop_table :clipboard_items
      create_table :clipboard_items do |t|
        t.integer :sidebar_tree_id, :null => false
        t.integer :document_id, :null => false
        t.primary_key :document_id
      end
      add_index   :clipboard_items, :sidebar_tree_id
      add_index   :clipboard_items, :document_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :clipboard_items
      create_table :clipboard_items, :id => false do |t|
        t.integer :sidebar_tree_user_id, :null => false
        t.integer :document_id, :null => false
        t.primary_key :document_id
      end
      add_index   :clipboard_items, :sidebar_tree_user_id
      add_index   :clipboard_items, :document_id
    end
  end
end
