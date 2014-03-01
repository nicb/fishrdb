#
# $Id: 20091014200120_add_children_class_control_to_documents.rb 468 2009-10-17 02:21:36Z nicb $
#
class AddChildrenClassControlToDocuments < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :documents, :allowed_children_classes, :string, :limit => 1024 # default -> nil
      add_column :documents, :allowed_sibling_classes, :string, :limit => 1024 # default -> nil
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :documents, :allowed_children_classes
      remove_column :documents, :allowed_sibling_classes
    end
  end

end
