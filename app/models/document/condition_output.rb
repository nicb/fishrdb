#
# $Id: condition_output.rb 502 2010-05-30 20:56:50Z nicb $
#
# facade methods for output
#

require 'string_extensions'

module DocumentParts

  module ConditionOutput

	protected
	
		def convert_newlines_to_html(attr)
			orig = read_attribute(attr)
			return orig.is_a?(String) ? orig.newlines_to_html : orig
		end
	
	public

    #
    # name
    #
		def raw_name
			return read_attribute('name')
		end

		def cleansed_name
			result = self.name.gsub('_'," ").strip
			return result
		end

    def cleansed_full_name
      return [name_prefix, cleansed_name].conditional_join(' ')
    end
	
    #
    # description level
    #
		def description_level_described
			return description_level.level
		end

    #
    # description and notes
    #
    def raw_description
      return read_attribute('description')
    end

		def description
			return convert_newlines_to_html('description')
		end
	
    def raw_note
      return read_attribute('note')
    end

		def note
			return convert_newlines_to_html('note')
		end
	
  end

end
