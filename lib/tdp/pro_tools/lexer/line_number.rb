#
# $Id: line_number.rb 587 2010-12-20 02:22:37Z nicb $
#
require 'singleton'

module Tdp

  module ProTools

    module Lexer

	    class LineNumber
	
	      attr_reader :n
	
	      include Singleton
	
	      def initialize
	        @n = 1
	      end
	
	      def bump(n = 1)
	        @n += n
	      end

          def reset
            @n = 0
          end
	
	    end

    end

  end

end
