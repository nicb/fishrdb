#
# $Id
# 

module DocumentParts

	module PublicAccess
	
	  def public_access?
	    return public_access
	  end
	
	  def public_access_check
	    return public_access? ? 'checked' : ''
	  end
	
	  def public_access_uncheck
	    return !public_access? ? 'checked' : ''
	  end
	
	  def public_access_div
	    prepo = public_access? ? '' : 'not_'
	    result = "consultation_#{prepo}allowed"
	    return result
	  end
	
	  def public_access_display
	    pa =  public_access? ? 'S&Igrave;' : "NO"
	    result = "<span class='#{public_access_div}'>" + pa + '</span>'
	    return result
	  end
	
	end

end
