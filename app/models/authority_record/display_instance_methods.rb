#
# $Id: display_instance_methods.rb 324 2009-03-06 04:26:22Z nicb $
#

module AuthorityRecordParts

  module DisplayMethods

    module Base

		  def variant?
		    return (self.class.name =~ /Variant$/)
		  end
		
		  def accepted_form
		    if variant?
		      result = self.send(self.class.reference_method)
		    else
		      result = self
		    end
		  end
		
		  #
		  # autocomplete helpers (to be subclassed)
		  #
		
		  def autocomplete_display
		    return name
		  end
		
		  def autocomplete_public_display
		    return name
		  end
	
	  end

		module PersonNameParts
	
	    include TextHelper
	    include DateHelper
	
		  def autocomplete_display
		    dates = year_range_string(self.date_start, self.date_end)
		    fn = self.first_name ? self.first_name : ''
		    result = sprintf("%s|%s|%d", truncate(self.name,15), truncate(fn + ' ' + dates,15), self.id)
		    return result
		  end
	
		end
		
		module CollectiveNameParts
		
	    include TextHelper
	    include DateHelper
	
		  def autocomplete_display
		    dates = year_range_string(self.date_start, self.date_end)
		    result = sprintf("%s|%s|%d", truncate(self.name,20), truncate(dates,15), self.id)
		    return result
		  end
	
		end
		
	  module ScoreTitleParts
		
	    include TextHelper
	
		  def autocomplete_display
		    result = sprintf("%-s|%-s|%d", truncate(self.name,20), truncate(self.organico,20), self.id)
		    return result
		  end
	
		end

  end

end
