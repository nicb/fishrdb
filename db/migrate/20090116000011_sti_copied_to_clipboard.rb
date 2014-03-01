#
# $Id: 20090116000011_sti_copied_to_clipboard.rb 285 2009-01-17 23:13:46Z nicb $
#
# This add a small field into the SidebarTreeItem object to save the
# "copied-to-clipboard" information
#
class StiCopiedToClipboard < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :sidebar_tree_items, :copied_to_clipboard, :string, :limit => 4, :null => false, :default => "no"
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :sidebar_tree_items, :copied_to_clipboard
    end
  end
end
