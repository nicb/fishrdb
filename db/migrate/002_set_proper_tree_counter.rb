#
# $Id: 002_set_proper_tree_counter.rb 124 2008-01-06 16:19:17Z nicb $
#
# this migration changes the 'documents_count' name into the 'children_count'
# one, necessary for the 'acts_as_tree' to work properly
#
class SetProperTreeCounter < ActiveRecord::Migration
  def self.up
  	ActiveRecord::Base.transaction do
		add_column 'documents', 'children_count', :integer, :default => 0
	end
		Document.find(:all).each do
			|d|
			size = Document.find(:all, :conditions => ["parent_id = ?", d.read_attribute('id')]).size
			puts("\tMigrating \"#{d.name}\", children size: #{size}") if size > 0
			d.update_attribute('children_count', size)
			d.save!
		end
		remove_column 'documents', 'documents_count'
  end

  def self.down
  	ActiveRecord::Base.transaction do
		add_column 'documents', 'documents_count', :integer, :default => 0
	end
		Document.find(:all).each do
			|d|
			size = Document.find(:all, :conditions => ["parent_id = ?", d.read_attribute('id')]).size
			puts("\tReverting \"#{d.name}\", children size: #{size}") if size > 0
			d.update_attribute('documents_count', size)
			d.save!
		end
		remove_column 'documents', 'children_count'
  end
end
