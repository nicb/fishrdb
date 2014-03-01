#
# $Id: 20090201014226_add_prefix_and_document_form_to_documents.rb 327 2009-03-09 21:34:37Z nicb $
#
class AddPrefixAndDocumentFormToDocuments < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.transaction do
      add_column :documents, :name_prefix, :string, :limit => 128
      add_column :documents, :forma_documento_score, :string, :limit => 512
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :documents, :name_prefix
      remove_column :documents, :forma_documento_score
    end
  end

end
