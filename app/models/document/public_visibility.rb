#
# $Id
# 
module DocumentParts

	module PublicVisibility
	
	  def public_visibility?
	    return public_visibility
	  end
	
	  def public_visibility_check
	    return public_visibility? ? 'checked' : ''
	  end
	
	  def public_visibility_uncheck
	    return !public_visibility? ? 'checked' : ''
	  end
	
	  def public_visibility_div
	    prepo = public_visibility? ? '' : 'not_'
	    result = "public_visibility_#{prepo}allowed"
	    return result
	  end
	
	  def public_visibility_display
	    pa =  public_visibility? ? 'S&Igrave;' : "NO"
	    result = "<span class='#{public_visibility_div}'>" + pa + '</span>'
	    return result
	  end
	
	protected
	
	  def iterate_public_visibility_set(bool)
			current = read_attribute(:public_visibility)
			return bool if bool == current # don't do anything if no change is required
	    write_attribute(:public_visibility, bool)
	    save
	    children(true).each do
	      |c|
	      c.iterate_public_visibility_set(bool)
	    end
      logger.debug(">>> record #{name}.iterate_public_visibility_set(#{bool}), lock_version is now #{self.lock_version}")
			bool
	  end
	
	public
	
	  def public_visibility=(bool)
	    iterate_public_visibility_set(bool)
	  end
	
	end

end
