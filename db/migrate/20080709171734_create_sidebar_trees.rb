#
# $Id: 20080709171734_create_sidebar_trees.rb 234 2008-07-14 06:54:57Z nicb $
#
class CreateSidebarTrees < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :sidebar_trees, :id => false do |t|
        t.integer 'user_id', :null => false
        t.primary_key :user_id
      end
      add_index   'sidebar_trees', :user_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :sidebar_trees
    end
  end
end
