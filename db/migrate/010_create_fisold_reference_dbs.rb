#
# $Id: 010_create_fisold_reference_dbs.rb 173 2008-02-22 11:52:00Z nicb $
#
require 'yaml'

def load_table
  top_dir = File.dirname(__FILE__) + '/../..'
  fixture_dir = top_dir + '/test/fixtures'
  ydata = YAML.load(File.open(fixture_dir + '/fisold_reference_dbs.yml'))
  ydata.each_value do
    |v|
    FisoldReferenceDb.create!(v)
  end
end

class CreateFisoldReferenceDbs < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :fisold_reference_dbs do |t|
	      t.string  :name
        t.integer :documents_count, :default => 0
	    end
      load_table
    end
    ActiveRecord::Base.transaction do
      add_column  'documents', 'fisold_reference_db_id', :integer, :null => true
      add_index   'documents', ["fisold_reference_db_id"]
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table    :fisold_reference_dbs
      remove_index  'documents', 'fisold_reference_db_id'
      remove_column 'documents', 'fisold_reference_db_id'
    end
  end
end
