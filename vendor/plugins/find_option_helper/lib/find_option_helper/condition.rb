#
# $Id: condition.rb 538 2010-08-23 00:19:46Z nicb $
#

require 'find_option_helper/find'
require 'find_option_helper/exceptions'

module FindOptionHelper

  class Condition < Find
    attr_reader :cond_string, :place_holder

    def initialize(s, v = nil)
      val = v
      @cond_string = "(#{s})"
      if val
        @place_holder = build_place_holder
        unless val.is_a?(Hash)
          val = { self.place_holder => v } unless v.is_a?(Hash)
          @cond_string = "(#{s} (:#{self.place_holder.to_s}))"
        end
      end
      return super(val)
    end

    def to_option_value
      return self.cond_string
    end

    class <<self

      def key
        return :conditions
      end

    end

  private

    def build_place_holder
      return sprintf("val_%#x", self.object_id).gsub(/\./,'').intern
    end

  end

  class ConditionGroup < FindGroup

    def initialize(jl = 'and')
      return super(jl.strip)
    end

    def <<(fo)
      raise(FindClassMismatch, "class #{fo.class.name} not allowed in FindGroup \"#{key.to_s}\"") unless self.class.admit?(fo)
      case
        when fo.is_a?(Condition) : super(fo)
        when fo.is_a?(ConditionGroup) : super(fo.to_condition)
      end
    end

    def to_option
      k = self.class.key
      result = { k => [] }
      return result if self.group.empty?
      result[k][0] = '(' + self.group.map { |co| co.to_option_value }.join(" #{self.join_logic.to_s} ") + ')'
      result[k][1] = {}
      self.group.each do
        |co|
        result[k][1].update(co.value) if co.value
      end
      return result
    end

    def to_condition
      return Condition.new(to_option[:conditions][0], to_option[:conditions][1])
    end

    class <<self

      def admit?(fo)
        return super(fo) || fo.class == self
      end

      #
      # this function is needed because ConditionGroup mimicks Condition
      # sometimes
      #
      def find_option_group
        return self
      end

    end

  end

end
