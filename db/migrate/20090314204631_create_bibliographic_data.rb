#
# $Id: 20090314204631_create_bibliographic_data.rb 343 2009-03-22 22:57:05Z nicb $
#
class CreateBibliographicData < ActiveRecord::Migration
  def self.up
    create_table :bibliographic_data, :id => false do |t|
      
      t.integer   :bibliographic_record_id, :null => false

      t.string    :author_last_name
      t.string    :author_first_name
      # title is the :name field in the related document
      t.string    :journal
      t.integer   :volume
      t.integer   :number
      t.date      :issue_year_db_record
      t.string    :address
      t.string    :publisher
      t.date      :publishing_date_db_record, :default => nil
      t.string    :publishing_date_format, :limit => 32, :default => ''
      t.string    :publishing_date_input_parameters, :limit => 3, :default => '---'
      t.integer   :start_page
      t.integer   :end_page
      t.string    :language
      t.string    :translator_last_name
      t.string    :translator_first_name
      t.string    :editor_last_name
      t.string    :editor_first_name
      # authority meta-tags are somewhere else (document)
      t.text      :abstract
      # notes are the :note field in the related document

    end
    add_index :bibliographic_data, :bibliographic_record_id
  end

  def self.down
    drop_table :bibliographic_data
  end
end
