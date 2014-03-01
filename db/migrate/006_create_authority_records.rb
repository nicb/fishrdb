#
# $Id: 006_create_authority_records.rb 140 2008-01-13 21:10:28Z nicb $
#
class CreateAuthorityRecords < ActiveRecord::Migration
  def self.up
  	ActiveRecord::Base.transaction do
	    create_table :authority_records do |t|
    		t.string		"name", :limit => 1024, :default => "", :null => false
	
			t.string		"type", :limit => 128, :default => "", :null => false
			t.integer		"children_count", :default => 0
			t.integer		"creator_id", :null => false
			t.integer		"last_modifier_id", :null => false
			t.timestamps

			#
			# just for the PersonName subclass:
			#
    		t.string		"first_name", :limit => 1024, :default => nil

			#
			# just for the time-based subclass (CollectiveNameEquivalent):
			#
			t.date			"validity_start", :default => nil
			t.date			"validity_end", :default => nil

			#
			# just for the equivalent subclasses:
			#
			t.integer		"authority_record_id", :default => nil
	    end
		add_index 		"authority_records", ["creator_id"], :name => "fk_ar_creator_id"
		add_index 		"authority_records", ["last_modifier_id"], :name => "fk_ar_last_modifier_id"
		#
		# just for the "equivalent" classes
		#
		add_index		"authority_records", ["authority_record_id"], :name => "fk_ar_id"
	end
  end

  def self.down
  	ActiveRecord::Base.transaction do
    	drop_table :authority_records
	end
  end
end
