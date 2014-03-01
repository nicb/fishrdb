#
# $Id$
#
class AddOrganicoOnScoreTitleArs < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :authority_records, :organico, :text
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :authority_records, :organico
    end
  end
end
