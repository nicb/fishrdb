#
# $Id: create_search_index_and_friends.rb 541 2010-09-07 06:08:21Z nicb $
#
module SearchEngine

	class CreateSearchIndexAndFriends < ActiveRecord::Migration
	
	  class <<self
	
		  def up
	      create_search_indices
	      create_search_index_classes
	      create_search_index_class_references
		  end
		
		  def down
		    drop_table :search_indices
		    drop_table :search_index_classes
		    drop_table :search_index_class_references
		  end
	
	private
	
	    def create_search_indices
	      common_creator(:search_indices) do |t|
			    t.string :string, :limit => 16384, :null => false
			    t.string :field, :limit => 512, :null => false
			    t.references :record
	        t.string :reference_roots, :limit => 4096, :null => false # marshaled ids in hash format
	      end
	      add_index(:search_indices, :record_id)
	    end
	
	    def create_search_index_classes
	      common_creator(:search_index_classes) do |t|
			    t.string :class_name, :limit => 512, :null => false
	      end
	    end
	
	    def create_search_index_class_references
	      common_creator(:search_index_class_references, :id => false) do |t|
	        t.references :search_index
	        t.references :search_index_class
	      end
	      add_index(:search_index_class_references, :search_index_id)
	      add_index(:search_index_class_references, :search_index_class_id)
	    end
	
	    def common_creator(table_name, options = {})
		    ActiveRecord::Base.transaction do
	        create_table(table_name, options) do
	          |t|
	          yield(t)
	        end
	      end
	    end
	
	  end
	
	end

end
