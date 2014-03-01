#
# $Id$
#
class AddAcademicYearToBibliography < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :bibliographic_data, :academic_year, :string, :limit => 128
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :bibliographic_data, :academic_year
    end
  end
end
