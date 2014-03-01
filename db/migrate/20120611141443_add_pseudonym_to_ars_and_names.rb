#
# $Id: 20120611141443_add_pseudonym_to_ars_and_names.rb 616 2012-06-21 11:47:43Z nicb $
#
class AddPseudonymToArsAndNames < ActiveRecord::Migration

	class << self
	  def up
			ActiveRecord::Base.transaction do
				add_column :authority_records, :pseudonym, :string, :limit => 128
				add_column :names,             :pseudonym, :string, :limit => 128
			end
	  end
	
	  def down
			ActiveRecord::Base.transaction do
				remove_column :authority_records, :pseudonym
				remove_column :names,             :pseudonym
			end
	  end
	end

end
