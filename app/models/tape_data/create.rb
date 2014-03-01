#
# $Id: create.rb 426 2009-08-22 22:35:49Z nicb $
#

module TapeDataParts

  module Create

    def self.included(base)
      base.extend ClassMethods
    end

    class TapeDataInvalid < ActiveRecord::ActiveRecordError
    end

    module ClassMethods

    public 

      def create(parms = {})
        raise(TapeDataInvalid, "Missing tag field") unless parms.has_key?(:tag)
        parms[:inventory] = extract_inventory_number(parms.read_and_delete(:tag))
        return super(parms)
      end

    protected

      def extract_inventory_number(tag)
        (dummy, result) = tag.split('-')
        return result
      end

    end

  end

end
