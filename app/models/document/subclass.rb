#
# $Id: subclass.rb 454 2009-10-02 20:51:29Z nicb $
#

module DocumentParts
  module Subclass

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

    public

      def subclasses
        return super
      end

    end

  end
end
