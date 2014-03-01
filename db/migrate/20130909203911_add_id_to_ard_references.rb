#
# $Id: 20130909203911_add_id_to_ard_references.rb 637 2013-09-10 12:56:40Z nicb $
#
# The ArdReference object misbehaves during removal because it is lacking
# its own unique id. We add it and set up all old objects with that.
#

class AddIdToArdReferences < ActiveRecord::Migration

  def self.up
    ActiveRecord::Base.transaction { add_column :ard_references, 'id', :primary_key }
    #
    # no need to worry about filling up the column, it gets done automatically
    # when adding a primary key.
    #
  end

  def self.down
    ActiveRecord::Base.transaction { remove_column :ard_references, 'id' }
  end

end
