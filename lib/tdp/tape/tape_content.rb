#
# $Id: tape_content.rb 369 2009-04-17 03:40:30Z nicb $
#

module Tdp

  module Tape

		class TapeContent
		  attr_accessor :tag_start, :tag_end, :description
		
		  def initialize(ts, te)
		    @tag_start = ts
		    @tag_end = te
		    @description = ''
		  end
		
		  def description=(d)
		    @description += d
		  end
		
		end

  end

end
