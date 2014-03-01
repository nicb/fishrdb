#
# $Id: region.rb 576 2010-12-14 21:56:04Z nicb $
#

module Tdp

  module ProTools

    class Region

      attr_reader :name, :source_file, :speed
      attr_accessor :tape_direction, :duration, :length,
        :start_time, :end_time, :event_number, :track_ref,
        :source_start_time, :source_end_time

      def initialize(n, src)
        @name = n
        @source_file = src
        @speed = extract_speed
      end

      def source_file=(sf)
        @source_file = sf
        dir = self.source_file.index('RVRS')
        self.tape_direction = dir ? :REVERSE : :STRAIGHT
      end

      def add_event(event)
        self.event_number = event.event
        dir = self.source_file.index('RVRS')
        self.tape_direction = dir ? :REVERSE : :STRAIGHT
        self.start_time = event.start_time
        self.end_time = event.end_time
        self.duration = event.duration
        self.length = self.duration.to_cm(self.speed)
      end

    private

      def extract_speed
        return self.name.sub(/\A.*@([0-9,]+).*\Z/, '\1').sub(/,/, '.').to_f
      end

    end

  end

end
