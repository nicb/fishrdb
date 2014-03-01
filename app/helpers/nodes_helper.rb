#
# $Id: nodes_helper.rb 1 2007-09-25 18:13:27Z nicb $
#
module NodesHelper

	def NodesHelper.get_clipboard
  		return Node.find_by_name("__fishrdb_clipboard___")
	end
end
