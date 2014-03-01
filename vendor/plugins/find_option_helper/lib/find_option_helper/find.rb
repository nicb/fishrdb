#
# $Id: find.rb 538 2010-08-23 00:19:46Z nicb $
#
# This is the superclass for all Find subclasses
#
require 'find_option_helper/exceptions'

module FindOptionHelper

  class Find
    attr_reader :value
    
    def initialize(v)
      @value = v
    end

    def to_option_value
      return self.value
    end

    class <<self

      def find_option_group
        return (self.name + 'Group').constantize
      end

      def key
        raise(PureVirtualMethodCalled, "#{self.name}.key pure virtual method called")
      end

    end

  end

  class FindGroup
    attr_reader :group
    attr_accessor :join_logic

    def initialize(jl = ', ')
      @group = []
      @join_logic = jl
    end

    class <<self

      def admitted_class
        return self.name.sub(/Group/,'').constantize
      end

      def key
        return self.admitted_class.key
      end

      def admit?(fo)
        return fo.class == self.admitted_class
      end

    end

    def <<(fo)
      raise(FindClassMismatch, "class #{fo.class.name} not allowed in FindGroup \"#{self.class.key.to_s}\"") unless self.class.admit?(fo)
      self.group << fo
    end

    def to_option
      result = {}
      result = { self.class.key => self.group.map { |fo| fo.to_option_value.to_s }.join(self.join_logic) } unless self.group.empty?
      return result
    end

  end

end
