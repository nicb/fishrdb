#
# $Id: 20090223133709_add_visibility_to_document.rb 327 2009-03-09 21:34:37Z nicb $
#
class AddVisibilityToDocument < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column  :documents, :public_visibility, :boolean, :null => false, :default => true
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :documents, :public_visibility
    end
  end
end
