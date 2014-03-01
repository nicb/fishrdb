#
# $Id: 017_migrate_date_names_on_collective_ars.rb 220 2008-06-17 02:55:25Z nicb $
#
class MigrateDateNamesOnCollectiveArs < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      rename_column 'authority_records', 'validity_start', 'date_start'
      rename_column 'authority_records', 'validity_end', 'date_end'
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      rename_column 'authority_records', 'date_start', 'validity_start'
      rename_column 'authority_records', 'date_end', 'validity_end'
    end
  end
end
