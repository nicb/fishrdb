#
# $Id: context_sequence.rb 576 2010-12-14 21:56:04Z nicb $
#
require 'singleton'

module Tdp

	module ProTools

	    module Lexer
	
	    class SectionParser; end
	    class FilesInSession < SectionParser; end
	    class RegionsInSession < SectionParser; end
	    class TrackListing < SectionParser; end
	
	    class ContextSequence
	
	      include Singleton
	
	      attr_reader :contexts
	
	      PTS_CONTEXT_CLASSES = [ FilesInSession, RegionsInSession, TrackListing, ]
	
	      def initialize
	        @contexts = PTS_CONTEXT_CLASSES
	      end
	
	      def size
	        self.contexts.size
	      end
	
	    end

    end

  end

end
