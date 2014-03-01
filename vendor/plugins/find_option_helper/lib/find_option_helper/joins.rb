#
# $Id: joins.rb 538 2010-08-23 00:19:46Z nicb $
#

require 'find_option_helper/find'
require 'find_option_helper/exceptions'

module FindOptionHelper

  class Joins < Find

    def to_option_value
      return super.to_s.intern # make sure it is a symbol
    end

    class <<self

      def find_option_group
        return JoinsGroup
      end

      def key
        return :joins
      end

    end

  end

  class JoinsGroup < FindGroup

    def <<(fo)
      raise(OnlyOneOptionAllowed, "A :joins option is already set (#{self.group.first.value})") unless self.group.empty?
      return super(fo)
    end

    def to_option
      result = {}
      result = { self.class.key => self.group.first.to_option_value } unless self.group.empty?
      return result
    end

  end

end
