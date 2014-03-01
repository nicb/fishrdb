#
# $Id: track.rb 576 2010-12-14 21:56:04Z nicb $
#

module Tdp

  module ProTools

    class Track

      attr_reader :name, :regions

      def initialize(n)
        @name = n
        @regions = []
      end
      
    end

  end

end
