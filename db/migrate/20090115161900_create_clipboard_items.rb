#
# $Id: 20090115161900_create_clipboard_items.rb 329 2009-03-12 23:27:58Z nicb $
#
class CreateClipboardItems < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :clipboard_items, :id => false, :force => true do |t|
        t.integer :sidebar_tree_user_id, :null => false
        t.integer :document_id, :null => false
        t.primary_key :document_id
      end
      add_index   :clipboard_items, :sidebar_tree_user_id
      add_index   :clipboard_items, :document_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_index   :clipboard_items, :sidebar_tree_user_id
      remove_index   :clipboard_items, :document_id
      drop_table :clipboard_items
    end
  end
end
