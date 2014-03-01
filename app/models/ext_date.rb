#
# $Id: ext_date.rb 455 2009-10-03 00:38:34Z nicb $
#
# This is an object which performs all date operations.
# As such, it is to be added to all date constants. Sub-objects will provide
# year-only, etc.
#
require 'date'

module ExtDate

	class Base
	  attr_reader :to_date, :input_parameters, :ed_format

    Base::IP_STRING_MAPPING = { :day => 0, :month => 1, :year => 2 }
    Base::DATE_SEPARATOR = '/'
    Base::DATE_DB_SEPARATOR = '-'

	  class << self
	
      def cleanse_date_hash(dh)
        result = dh
        if result
          result.keys.each do
            |k|
            result.delete(k) if result[k].blank?
          end
        end
        return result
      end

		  def date_hash_to_dbd_string(date_hash)
		    result = nil
        date_hash = cleanse_date_hash(date_hash)
		    if date_hash && !date_hash.empty? && date_hash.has_key?(:year)
          fields = [ date_hash[:year] ]
          if date_hash.has_key?(:month)
            fields << date_hash[:month].to_s
          else
            fields << default_month
          end
          if date_hash.has_key?(:day)
            fields << date_hash[:day].to_s
          else
            if date_hash.has_key?(:month)
              fields << default_day(date_hash[:month].to_i)
            else
              fields << default_day
            end
          end
          result = fields.join(DATE_DB_SEPARATOR)
		    end
		    return result
		  end

      def date_string_to_ymd(ds)
        result = nil
        unless ds.blank?
          (y, m, d) = ds.split('-')
          m = default_month unless m
          d = default_day(m) unless d
          result = [y.to_i, m.to_i, d.to_i]
        end
        return result
      end

      def date_hash_to_ip_string(date_hash)
        result = '---'
        if date_hash and !date_hash.blank?
          [:day, :month, :year].each do
            |k|
            result[IP_STRING_MAPPING[k]] = 'X' if date_hash.has_key?(k) && !date_hash[k].blank?
          end
        end
        return result
      end

      def default_day(month = 1)
        return '01'
      end
	
      def default_month
        return '01'
      end

      def default_year
        return '' # there's no default year...
      end

      def default_date_select_options
        result = {
          :include_blank => true,
          :start_year => 1800,
          :end_year => 2050,
          :use_month_names => %w(Gen Feb Mar Apr Mag Giu Lug Ago Set Ott Nov Dic),
        }
	      return result
      end

      def default_date_format_from_hash(h)
        fields = []
        [[:day, '%d'], [:month, '%m'], [:year, '%Y']].each do
          |a|
          fields << a[1] unless h[a[0]].blank?
        end
        return fields.join(DATE_SEPARATOR)
      end

    end # of class_methods

	  def initialize(dbd = nil, ips = '---', f = nil)
        @input_parameters = ips ? ips : '---'
		    @ed_format = f
        unless dbd.blank?
          if dbd.is_a?(String)
            dbd_string = dbd
          elsif dbd.is_a?(Hash)
            dbd = HashWithIndifferentAccess.new(dbd)
		        dbd_string = self.class.date_hash_to_dbd_string(dbd)
          elsif dbd.is_a?(Date)
            dbd_string = nil
            @date = dbd
          elsif dbd.is_a?(Fixnum)
            dbd_string = dbd.to_s
          else
            raise TypeError, "#{self.class.name}: argument class #{dbd.class.name} not recognized"
          end
          unless dbd_string.blank?
		        (year, month, day) = self.class.date_string_to_ymd(dbd_string)
	          @date = Date.new(year, month, day)
          end
        end
	  end
	
    def to_date
      return @date
    end

    def to_datetime
      return @date.to_datetime
    end

    def to_s(db = :mysql)
      result = ''
      case
        when to_date.is_a?(Date)      then   result = to_date.to_s(db)
        when to_date.is_a?(NilClass)  then   result = ''
        else                                 result = to_date.to_s
      end
      return result
    end
	
	  def to_display
      fmt = ed_format ? ed_format : default_date_format
	    return to_date ? to_date.strftime(fmt) : ''
	  end

    def day_was_set?
      return input_parameters[IP_STRING_MAPPING[:day]..IP_STRING_MAPPING[:day]] == 'X'
    end

    def month_was_set?
      return input_parameters[IP_STRING_MAPPING[:month]..IP_STRING_MAPPING[:month]] == 'X'
    end

    def year_was_set?
      return input_parameters[IP_STRING_MAPPING[:year]..IP_STRING_MAPPING[:year]] == 'X'
    end

    def date_select_options(pfx, disabled = false)
      result = self.class.default_date_select_options
      result[:prefix] = pfx
      result[:disabled] = disabled
      return result
    end

    def default_date_format
      fields = []
      [{:day => '%d'}, {:month => '%m'}, {:year => '%Y'}].each do
        |a|
        meth = a.keys[0].to_s + '_was_set?'
        fields << a.values[0] if send(meth)
      end
      return fields.join(DATE_SEPARATOR)
    end

    def date_format
      return ed_format ? ed_format : default_date_format
    end

protected

    def date_part(method)
      result = nil
      if to_date
        result = send(method.to_s + '_was_set?') ? to_date.send(method) : nil
      end
      return result
    end

public

    def day
      return date_part(:day)
    end

    def month
      return date_part(:month)
    end

    def year
      return date_part(:year)
    end

    def default_day
      return class_default_day
    end

	end

  class From < Base
  end

  class To < Base
    class << self

      DEFAULT_LAST_DAY = [ 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]

      def default_day(month = 12)
        return DEFAULT_LAST_DAY[month.to_i]
      end

      def default_month
        return '12'
      end

    end

  end
	
	class Year < Base

    def initialize(dbd = nil, ips = '--X', yf = '%Y')
      super(dbd, ips, yf)
    end

    def <=>(other)
      result = 0
      result = self.to_date <=> other.to_date if self.to_date && other.to_date
      return result
    end

	end
	
	class Interval
	  attr_reader :date_from, :date_to, :to_date_from, :to_date_to,
                :dfips, :dtips, :intv_format, :from_format, :to_format

    Interval::DATE_INTERVAL_SEPARATOR = '-'
	
	  def initialize(dbd_df = nil, dbd_dt = nil, dfips = '---', dtips = '---',  ifmt = '', ff = '', tf = '')
      @date_from = ExtDate::From.new(dbd_df, dfips, ff)
      @date_to = ExtDate::To.new(dbd_dt, dtips, tf)
	
	    @intv_format = ifmt
	  end
	
    class << self

	    def default_intv_format(from_fstring, to_fstring, sep = DATE_INTERVAL_SEPARATOR)
        fields = []
        [[from_fstring, '%DD'], [to_fstring, '%DA']].each do
          |a|
          fields << a[1] unless a[0].blank?
        end
        return fields.join('-')
	    end

    end
	
	  def to_display
	    result = ''
      result = intv_format.gsub(/%DD/, "#{@date_from.to_display}") if intv_format
	    result = result.gsub(/%DA/, "#{@date_to.to_display}")
	    return result
	  end

    #
    # methods required to make the embedded models work
    #

    def to_date_from
      return @date_from.to_date
    end

    def to_date_to
      return @date_to.to_date
    end

    def to_date_from_s(db = :mysql)
      return @date_from.to_s(db)
    end

    def to_date_to_s(db = :mysql)
      return @date_to.to_s(db)
    end

	  def from_format
	    return (date_from.ed_format.blank? ? '' : date_from.ed_format)
	  end
	
	  def to_format
	    return (date_to.ed_format.blank? ? '' : date_to.ed_format)
	  end

	  def dfips
	    return date_from.input_parameters
	  end
	
	  def dtips
	    return date_to.input_parameters
	  end

	end

end
