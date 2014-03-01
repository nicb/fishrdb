#
# $Id: status.rb 426 2009-08-22 22:35:49Z nicb $
#

module SidebarTreeItemParts

  module Status

	protected
	
	  def update_status(s)
	    update_attributes!(:status => s)
	  end

    def select_me
	    sidebar_tree.select_sidebar_item(self) unless self == Document.fishrdb_root
    end
	
	public

    def open_without_selecting_me
	    unless open?
	      update_status(:open)
        expose_children
	    end
    end

	  def open
      select_me
      open_without_selecting_me
	  end
	
	  def close
      select_me
	    unexpose_children
	    update_status(:closed)
	  end
	
	  def open?
	    return (status == :open)
	  end
	
	  def closed?
	    return (status == :closed)
	  end
	
	  def toggle
	    if open?
	      result = close
	    else
	      result = open
	    end
	    return result
	  end
	
	  def icon
	    result = 'document'
	    if potentially_has_children?
	      result = open? ? 'expanded' : 'collapsed'
	    end
	    master_icon_file_path = "fishrdb/sidebar_" + result + ".png"
	    return master_icon_file_path
	  end

  end

end
