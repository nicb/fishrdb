#
# $Id: adjust_dates.rb 324 2009-03-06 04:26:22Z nicb $
#

require 'hash_extensions'

module AuthorityRecordParts

  module AdjustDates

	  def self.included(base)
	    base.extend ClassMethods
	  end
	
	  module ClassMethods
	
		  def adjust_dates(fparams)
		    return fparams
		  end
	
	  end # end of class methods
	
	  module PersonNameParts
	
	    def self.included(base)
	      base.extend ClassMethods
	    end
	
	    module ClassMethods
	
	    protected
	
			  def get_date_interval(fparams)
			    result = ExtDate::Interval.new(fparams.read_and_delete_returning_empty_if_null('date_start'),
			                                   fparams.read_and_delete_returning_empty_if_null('date_end'),
			                                   fparams.read_and_delete_returning_empty_if_null('date_start_input_parameters'),
			                                   fparams.read_and_delete_returning_empty_if_null('date_end_input_parameters'),
			                                   fparams.read_and_delete_returning_empty_if_null('full_date_format'),
			                                   fparams.read_and_delete_returning_empty_if_null('date_start_format'),
			                                   fparams.read_and_delete_returning_empty_if_null('date_end_format'))
			
			    return result
		
			  end 
		
		  public
		
			  def adjust_dates(fparams)
		      fparams[:date] = get_date_interval(fparams)
			    return fparams
			  end
		
		  end # end of class methods
	
	  end

  end

end
