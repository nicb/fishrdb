#
# $Id$
#
class RemoveChildrenOrdering < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      remove_column :documents, :children_ordering
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      add_column :documents, :children_ordering, :string, :default => 'logic'
    end
  end
end
