#
# $Id: scanner.rb 587 2010-12-20 02:22:37Z nicb $
#
module Tdp

	module ProTools

    module Lexer

	    class Scanner
	
	      attr_reader   :filename, :lexdebug, :pro_tools_session
	      
	      def initialize(fn, dbg = false)
	        @filename = fn
	        @lexdebug = dbg
	        @pro_tools_session = scan
	      end
	
	    private
	
	      def scan
	        result = nil
	        File.open(self.filename, 'r') do
	          |fh|
              LineNumber.instance.reset
	          result = ProToolsSession.new(fh)
	          result.parse
	        end if filename
	        result
	      end
			
			end

    end
	
	end

end
