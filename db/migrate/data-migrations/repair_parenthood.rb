#
# $Id: repair_parenthood.rb 164 2008-02-10 05:54:21Z nicb $
#
# All the work of this migration is performed in the 'repair_parenting.rb'
# library in lib/
#

require 'repair_parenting'

class RepairParenthood < ActiveRecord::Migration

	include RepairParenting

	def self.up
 	  	ActiveRecord::Base.transaction do
			RepairParenting.repair(File.basename(__FILE__))
 		end
	end

	def self.down
 	  	ActiveRecord::Base.transaction do
			RepairParenting.unrepair(File.basename(__FILE__))
 		end
	end
end
