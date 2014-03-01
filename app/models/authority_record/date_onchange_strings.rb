#
# $Id: date_onchange_strings.rb 324 2009-03-06 04:26:22Z nicb $
#

module AuthorityRecordParts

  module DateOnChangeStrings
	
	  def self.included(base)
	    base.extend ClassMethods
	  end
	
	  module ClassMethods
	
	    include OnchangeStringsHelper
	
		  def date_onchange_string(tag)
		    return onchange_string("#{tag}_date_changed", 'date_start', 'date_end', 'authority_record', 'ar')
		  end
		
	  end

  end

end
