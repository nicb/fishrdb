#
# $Id: order.rb 538 2010-08-23 00:19:46Z nicb $
#

require 'find_option_helper/find'

module FindOptionHelper

  class Order < Find

    class <<self

      def find_option_group
        return OrderGroup
      end

      def key
        return :order
      end

    end

  end

  class OrderGroup < FindGroup
  end

end
