#
# $Id: 20080728180754_ard_reference_cleanup.rb 259 2008-07-28 18:26:12Z nicb $
#
require 'ard_reference_cleaner'

class ArdReferenceCleanup < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      ArdReferenceCleaner.clean_ard_references
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
