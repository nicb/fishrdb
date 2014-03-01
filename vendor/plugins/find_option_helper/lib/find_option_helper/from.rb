#
# $Id: from.rb 538 2010-08-23 00:19:46Z nicb $
#

require 'find_option_helper/find'

module FindOptionHelper

  class From < Find

    class <<self

      def find_option_group
        return FromGroup
      end

      def key
        return :from
      end

    end

  end

  class FromGroup < FindGroup
  end

end
