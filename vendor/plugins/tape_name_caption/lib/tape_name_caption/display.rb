#
# $Id: display.rb 555 2010-09-12 19:53:28Z nicb $
#

module TapeNameCaption

  module Display

    include TapeNameCaption::Parse::Map
    include TapeNameCaption::Constants

    def display
      result_to_display = ''
      unless self.malformed?
	      result = []
	      DISPLAY_SEQ.each do
	        |key|
	        v = REGEXP_MAP[key]
	        result << remap(key, v[:map])
	      end
        result << ('Dim: ' + self.size)
        name = result.shift
        num  = result.shift
        name_num = num.blank? || name =~ /\w+[0-9]+/ ? name : name + ' ' + num
        result_to_display += (' (' + name_num + ', ' + result.join(', ') + ')')
      end
      return result_to_display
    end

  private

    class DisplayRegexpFailed < StandardError; end

    def remap(key, map)
      result = []
      found = false
      map.each do
        |k, v|
        if send(key) =~ k
          result << send(key).sub(k, v)
          found = true
        end
      end
      raise(DisplayRegexpFailed, "Display Regexp failed for field #{key} (#{send(key)}, map #{map.inspect})") unless found
      return result.join(' ')
    end

  end

end
