#
# $Id: files_in_session.rb 586 2010-12-20 00:15:47Z nicb $
#
module Tdp

	module ProTools

    module Lexer

	    class FileInSession
	
	      attr_reader :audio_file, :path
	
	      def initialize(af, p)
	        @audio_file = af
	        @path = p
	      end
	
	    end
	
	    class FilesInSession < SectionParser
	
	      attr_accessor :files
	
	      def initialize(fh)
	        @files = []
	        super(fh)
	      end
	
	      def parse(line = '')
	        line = parse_headers(line)
	        line = parse_lines(line)
	      end
	
	    private
	
	      FILES_IN_SESSION_HEADER_LINES = [ 'F I L E S  I N  S E S S I O N', 'Filename	Location' ]
	
	      def parse_headers(line)
	        common_parse_headers(line, FILES_IN_SESSION_HEADER_LINES)
	      end
	
	      def parse_lines(line)
	
	        result = common_parse(line) do
	          |l|
	          (file, path) = l.split(/\t/)
	          self.files << FileInSession.new(file, path)
	        end
	
	        result
	      end
	
	    end

    end

  end

end
