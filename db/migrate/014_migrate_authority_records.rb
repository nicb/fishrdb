#
# $Id: 014_migrate_authority_records.rb 204 2008-04-19 21:20:26Z nicb $
#
class MigrateAuthorityRecords < ActiveRecord::Migration
  def self.up
    bootstrap_user = User.authenticate('bootstrap', '__fishrdb_bootstrap__')
  	ActiveRecord::Base.transaction do
      AuthMigrator.create_authority_records_from_documents(bootstrap_user)
    end
  end

  def self.down
	#
	# since no records are erased during migration,
	# no records should be restored during rollback.
	#
  # However: authority records should indeed be destroyed but: what should be
  # done with newly added ones?
  end
end
