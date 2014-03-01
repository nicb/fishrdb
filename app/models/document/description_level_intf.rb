#
# $Id: description_level_intf.rb 404 2009-05-05 09:32:46Z nicb $
#
# Now that description_level is not an ActiveRecord::Base object any longer we
# must provide a couple of methods to service it anyway

module DocumentParts

	module DescriptionLevelIntf
	
	  def description_level
	    result = nil
	    result = DescriptionLevel.find(description_level_id) if description_level_id
	    return result
	  end
	
	  def description_level=(dl)
	    if dl.is_a?(Fixnum)
	      description_level_id = dl
	    else
	      description_level_id = dl.id
	    end
	    return description_level
	  end

    def public_description_level_title
      return cleansed_full_name
    end
	
	end

end
