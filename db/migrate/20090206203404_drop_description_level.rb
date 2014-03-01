#
# $Id: 20090206203404_drop_description_level.rb 327 2009-03-09 21:34:37Z nicb $
#
class DropDescriptionLevel < ActiveRecord::Migration

  def self.transfer_dls
    say_with_time('transfer description levels...') do
      Document.find(:all).map { |d| d.update_attribute(:dl_id, d.description_level_id); d.save }
    end
  end

  def self.up
    ActiveRecord::Base.transaction do
      add_column :documents, :dl_id, :integer, :limit => 11
      transfer_dls
      execute("alter table documents drop foreign key fk_doc_dl")
      remove_column :documents, :description_level_id
      rename_column :documents, :dl_id, :description_level_id
      drop_table :description_levels
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
