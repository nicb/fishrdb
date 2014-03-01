#
# $Id: regions_in_session.rb 586 2010-12-20 00:15:47Z nicb $
#
module Tdp

	module ProTools

    module Lexer

	    class RegionInSession
	
	      attr_reader :region, :file
	
	      def initialize(r, f)
	        @region = r
	        @file = f
	      end
	
	    end
	
	    class RegionsInSession < SectionParser
	
	      attr_accessor :regions
	
	      def initialize(fh)
	        @regions = []
	        super(fh)
	      end
	
	      def parse(line = '')
	        line = parse_headers(line)
	        line = parse_lines(line)
	      end
	
	    private
	
	      REGIONS_IN_SESSION_HEADER_LINES = [ 'R E G I O N S  I N  S E S S I O N', 'REGION NAME	Source File' ]
	
	      def parse_headers(line)
	        common_parse_headers(line, REGIONS_IN_SESSION_HEADER_LINES)
	      end
	
	      def parse_lines(line)
	
	        result = common_parse(line) do
	          |l|
	          (region, file) = l.split(/\t/)
	          self.regions << RegionInSession.new(region, file)
	        end
	
	        result
	      end
	
	    end

    end

  end

end
