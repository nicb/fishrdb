#
# $Id: 007_create_documents_authority_records.rb 204 2008-04-19 21:20:26Z nicb $
#
class CreateDocumentsAuthorityRecords < ActiveRecord::Migration
  def self.up
  	ActiveRecord::Base.transaction do
	    create_table :authority_records_documents, :id => false do |t|
			t.integer		"authority_record_id",	:null => false
			t.integer		"document_id",			:null => false
    		t.integer   	"creator_id",			:null => false
    		t.integer   	"last_modifier_id",		:null => false
			t.timestamps
		end
		add_index 		"authority_records_documents", ["authority_record_id"], :name => "fk_drd_authority_record_id"
		add_index 		"authority_records_documents", ["document_id"], :name => "fk_drd_document_id"
		add_index 		"authority_records_documents", ["creator_id"], :name => "fk_drd_creator_id"
		add_index 		"authority_records_documents", ["last_modifier_id"], :name => "fk_drd_last_modifier_id"
		remove_column	"authority_records_documents", :id
	end
  end

  def self.down
  	ActiveRecord::Base.transaction do
    	drop_table :authority_records_documents
	end
  end
end
