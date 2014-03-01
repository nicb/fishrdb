#
# $Id: condition_input.rb 324 2009-03-06 04:26:22Z nicb $
#
# input conditioning
#

module DocumentParts

  module ConditionInput

	public

    def self.included(base)
      base.extend ClassMethods
    end
	
    module ClassMethods

			protected
			
				def _condition_input_(parms)
					#
					# This method can be used by subclasses to do some pre-save
					# input conditioning. In the base class, it does nothing,
					# successefully
					#
					return parms
				end
			
			public
			
				def condition_input(parms)
					parms = self._condition_input_(parms)
			
					FormHelper.close_conditioning(parms)
			
					return parms
				end
		
		  end

    end

end
