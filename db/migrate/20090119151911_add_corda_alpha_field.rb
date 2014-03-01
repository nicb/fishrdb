#
# $Id: 20090119151911_add_corda_alpha_field.rb 296 2009-01-23 05:31:25Z nicb $
#
class AddCordaAlphaField < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :documents, :corda_alpha, :string, :limit => 16
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :documents, :corda_alpha
    end
  end
end
