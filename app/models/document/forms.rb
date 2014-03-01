#
# $Id: forms.rb 343 2009-03-22 22:57:05Z nicb $
#

module DocumentParts

  module Forms

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      #
      # these methods are supposed to retrieve the forms for partials that 
      # allow editing and creation
      #
      def edit_form
        return name.underscore.downcase + '/edit'
      end

      def new_form
        return edit_form
      end

    end

  end

end
