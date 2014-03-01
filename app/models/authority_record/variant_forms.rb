#
# $Id: variant_forms.rb 324 2009-03-06 04:26:22Z nicb $
#

module AuthorityRecordParts

  module VariantForms

	public
	
	  def create_variant_form(user, attrs)
	    (search_string, params) = self.class.find_conditions(attrs)
	    ar = self.class.find(:first, :conditions => [search_string, params])
	    unless ar
	      ar = self.class.variant_form_class.find(:first, :conditions => [search_string, params])
	    end
	    unless ar
	      attrs[:creator] = attrs[:last_modifier] = user
	      ar = self.variants.create(attrs)
	    end
	
	    return ar
	  end
	
	  def variants
	    return self.send(self.class.variant_form_method)
	  end

  end

end
