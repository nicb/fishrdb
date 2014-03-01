#
# $Id: tape_item.rb 558 2010-11-23 02:25:47Z nicb $
#

module Tdp

  module Csv

    class TapeItem

      attr_reader :attributes

      class << self

        def convert_to_method_name(attr_name)
          return attr_name.to_s.downcase.gsub(/[.\/]/, '_').sub(/\s+.*$/, '')
        end

        def convert_value(value)
          return value ? value.gsub(/"/, '\"') : value
        end

        def excluded?(key)
          result = false
          excluded_attributes = [ 'SF', 'DATA IN', 'DATA OUT' ]
          excluded_attributes.each do
            |k|
            if key == k
              result = true
              break
            end
          end
          return result 
        end

      end

      def make_first_class_attributes
        attributes.each do
          |k, v|
          unless self.class.excluded?(k)
            kname = self.class.convert_to_method_name(k)
            value = v ? v.gsub(/"/, '\"') : v
            unless kname.blank?
              instance_eval("@#{kname} = \"#{value}\"")
              self.class.module_eval("def #{kname}; return @#{kname}; end")
              self.class.module_eval("def #{kname}=(v); return @#{kname} = v; end")
            end
          end
        end
      end

      def initialize(attrs)
        @attributes = attrs
        make_first_class_attributes
      end

      def sf
        return attributes['SF'].to_i * 1000
      end

      def data_in
        return conv_date(attributes['DATA IN'])
      end

      def data_fi
        return conv_date(attributes['DATA FI'])
      end

    private

      def conv_date(date_string)
        result = nil
        if date_string
          (y, m, d) = date_string.split('/')
          result = Date.civil(y.to_i, m.to_i, d.to_i)
        end
        return result
      end

    end
    
  end

end
