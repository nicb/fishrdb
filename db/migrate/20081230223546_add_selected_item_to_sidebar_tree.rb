#
# $Id: 20081230223546_add_selected_item_to_sidebar_tree.rb 278 2009-01-13 01:33:33Z nicb $
#
class AddSelectedItemToSidebarTree < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :sidebar_trees, :selected_item_id, :integer, :null => true, :default => nil
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :sidebar_trees, :selected_item
    end
  end
end
