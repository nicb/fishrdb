#
# $Id: selection.rb 324 2009-03-06 04:26:22Z nicb $
#

module SidebarTreeItemParts

  module Selection

	  def selected?
	    return sidebar_tree.selected_item == self
	  end
	
	  def selection_id_tag
	    return selected? ? 'selected' : 'unselected'
	  end

  end

end
