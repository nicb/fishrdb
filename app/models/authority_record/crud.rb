#
# $Id: crud.rb 324 2009-03-06 04:26:22Z nicb $
#
# CRUD functions
#

require 'hash_extensions'

module AuthorityRecordParts

  module Crud

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

    public

      def create_from_form(fparams)
        fparams.delete('id') # can't be mass-assigned
		    fparams = adjust_dates(fparams)
        return create(fparams)
      end

    end

    def update_from_form(fparams)
      result = self
      fparams = HashWithIndifferentAccess.new(fparams)
			fparams.delete(:id) 		# can't be mass-assigned
			fparams.delete(:type) 	# can't be mass-assigned

      fparams = self.class.adjust_dates(fparams)
      return update_attributes!(fparams)
    end

  end

end
