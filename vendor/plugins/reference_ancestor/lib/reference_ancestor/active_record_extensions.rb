#
# $Id: active_record_extensions.rb 537 2010-08-22 02:42:25Z nicb $
#

module ReferenceAncestor

  module ActiveRecordExtensions

    module ClassMethods

      class NotAnActiveRecord < StandardError; end

      #
      # +reference_ancestor+ is a class method that allows to find the common
      # parent class +right before+ ActiveRecord::Base, that is, the direct
      # descendant of ActiveRecord::Base.
      #
      # Example:
      #
      # class This < ActiveRecord::Base; end
      #
      # class That < This; end
      #
      # class TheOther < That; end
      #
      # TheOther.reference_ancestor     => This
      # That.reference_ancestor         => This
      #
      def reference_ancestor
        last = self
        result = last

        while (last != ActiveRecord::Base)
          result = last
          last = last.superclass
          raise(NotAnActiveRecord, "Class #{self.name} is not an ActiveRecord::Base child") unless last
        end

        return result
      end

    end

  end

end
