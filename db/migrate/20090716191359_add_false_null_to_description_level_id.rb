#
# $Id: 20090716191359_add_false_null_to_description_level_id.rb 432 2009-08-30 21:44:20Z nicb $
#
class AddFalseNullToDescriptionLevelId < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      change_column :documents, :description_level_id, :integer, :limit => 8, :null => false
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      change_column :documents, :description_level_id, :integer, :limit => 8, :null => true
    end
  end
end
