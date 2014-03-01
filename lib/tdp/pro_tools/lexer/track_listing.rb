#
# $Id: track_listing.rb 576 2010-12-14 21:56:04Z nicb $
#
module Tdp

	module ProTools

    module Lexer

	    class TrackListing < SectionParser
	
	      attr_accessor :tracks
	
	      def initialize(fh)
	        @tracks = []
	        super(fh)
	      end
	
	      def parse(line = '')
	        line = parse_headers(line)
	        line = parse_lines(line)
	        line
	      end
	
	      def find_track_like(pattern)
	        tracks.map { |t| t if t.name =~ pattern }.compact
	      end
	
	    private
	
	      TRACK_LISTING_HEADER_LINES = [ 'T R A C K  L I S T I N G' ]
	
	      def parse_headers(line)
	        common_parse_headers(line, TRACK_LISTING_HEADER_LINES)
	      end
	
	      def parse_lines(line)
	
	        while(line)
	          self.tracks << Track.new(self.file_handle)
	          line = self.tracks.last.parse(line)
	        end
	
	        line
	      end
	
	    end

    end

  end

end
