#
# $Id: sidebar_display.rb 327 2009-03-09 21:34:37Z nicb $
#

module DocumentParts

  module SidebarDisplay

	  def sidebar_name
	    return cleansed_full_name
	  end
	
	  def sidebar_tip
	    return sidebar_name
	  end
	
	  def sidebar_dates
	    return dates_to_be_displayed
	  end
	
	end

end
