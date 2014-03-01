#
# $Id: exceptions.rb 584 2010-12-19 22:12:55Z nicb $
#

module Tdp

  module ProTools

    class CatchableException < StandardError; end

    class RegionNotFound < CatchableException; end
    class DuplicateRegion < CatchableException; end
    class TrackNumberConflict < CatchableException; end
    class TrackNotFound < CatchableException; end

  end

end
