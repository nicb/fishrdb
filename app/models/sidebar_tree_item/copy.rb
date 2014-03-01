#
# $Id: copy.rb 362 2009-04-12 16:34:55Z nicb $
#

module SidebarTreeItemParts

  module Copy
	  #
	  # copied_to_clipboard methods
	  #
	  def find_clipboard_item
	    return ClipboardItem.find(:first,
	                              :conditions => [ "sidebar_tree_id = ? and document_id = ?",
	                              sidebar_tree.id, document.id ] )
	  end
	
	  def copied_to_clipboard?
	    #
	    # check clipboard before answering
	    #
	    clip = find_clipboard_item
	    if clip and copied_to_clipboard == 'no'
	      update_attributes!(:copied_to_clipboard => 'yes')
	    end
	    return copied_to_clipboard == 'yes'
	  end
	
	  def copy_to_clipboard
	    clip = ClipboardItem.create(:sidebar_tree => sidebar_tree, :document => document)
	    update_attributes!(:copied_to_clipboard => 'yes')
	  end
	
	  def remove_from_clipboard
	    clip = find_clipboard_item
	    clip.destroy if clip
	    update_attributes!(:copied_to_clipboard => 'no')
	  end

  end

end
