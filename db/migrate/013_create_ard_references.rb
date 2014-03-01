#
# $Id: 013_create_ard_references.rb 193 2008-03-30 22:24:03Z nicb $
# 
# In the up direction, this migration renames the old habtm table
# "authority_records_documents" in favor of the new hm:t table ard_references.
#
# there is the addition of the 'type' column since the relation is polymorphic
#
class CreateArdReferences < ActiveRecord::Migration
  def self.up
  	ActiveRecord::Base.transaction do
      rename_table :authority_records_documents, :ard_references
      add_column   :ard_references, 'type', :string, :limit => 128, :null => false
    end
  end

  def self.down
  	ActiveRecord::Base.transaction do
      remove_column :ard_references, 'type'
      rename_table :ard_references, :authority_records_documents
    end
  end
end
