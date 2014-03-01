#
# $Id: display.rb 502 2010-05-30 20:56:50Z nicb $
#

module Tdp

  module Box

    class Display

      attr_accessor :location, :notes

      def initialize(loc)
        @location = loc
        @notes = []
      end

    end

  end

end
