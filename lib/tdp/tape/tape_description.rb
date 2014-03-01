#
# $Id: tape_description.rb 369 2009-04-17 03:40:30Z nicb $
#
#

require 'tape_content'

module Tdp

  module Tape

		class TapeDescription
		  attr_accessor :tag, :description
		  
		  def initialize
		    @tag = ''
		    @description = ''
		  end
		
		  def description=(string)
		    @description += string
		  end
		
      def tag=(string)
        @tag = string.gsub(/\ANastro\s+/, '')
      end

		end

  end

end
