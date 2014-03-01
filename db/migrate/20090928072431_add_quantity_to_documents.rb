#
# $Id: 20090928072431_add_quantity_to_documents.rb 462 2009-10-12 01:07:40Z nicb $
#
class AddQuantityToDocuments < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      change_table :documents do
        |c|
        c.integer :quantity, :null => false, :default => 1
      end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :documents, :quantity
    end
  end
end
