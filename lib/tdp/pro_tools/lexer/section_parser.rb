#
# $Id: section_parser.rb 586 2010-12-20 00:15:47Z nicb $
#
module Tdp

	module ProTools

    module Lexer

	    class SectionParser
	
	      attr_reader :file_handle, :context_sequence, :line_number
	
	      def initialize(fh)
	        @file_handle = fh
	        @context_sequence = ContextSequence.instance
	        @line_number = LineNumber.instance
	      end
	
	      def parse(line = '')
	        raise(PureVirtualMethodCalled, "SectionParser#parse pure virtual method called")
	      end
	
	    protected
	
	      def set_value(method, line)
	        (tag, value) = line.split(/\t/)
	        value = value.to_i if tag =~ /^#\s+OF/
	        self.send(method.to_s + '=', value)
	      end
	
	      def readline
	        line = nil
	        unless self.file_handle.eof?
	          line = self.file_handle.gets.chomp
	          self.line_number.bump
	        end
	        line
	      end
	
	      def gobble_empty_lines(line)
	        while(line =~ /^\s*$/)
	          line = self.readline
	        end
	        line
	      end
	
	      def common_parse_headers(line, headers)
	
	        headers.each do
	          |l|
	          raise(WrongSectionHeader, "#{self.line_number.n}: expecting \"#{l}\" but got \"#{line}\"") unless line == l
	          line = self.readline
	        end
	
	        line
	      end
	
	      def common_parse(line)
	
	        while(line !~ /^\s*$/)
	          yield(line)
	          line = self.readline
	        end
	
	        line
	      end
	
	    end

    end

  end

end
