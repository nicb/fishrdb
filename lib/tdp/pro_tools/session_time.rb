#
# $Id: session_time.rb 594 2010-12-25 23:52:11Z nicb $
#

module Tdp

  module ProTools

    class SessionTime

      MIN_TIME_VALUE = 0.005 unless defined?(MIN_TIME_VALUE)

      attr_reader :minutes, :seconds

      def initialize(mins, secs)
        @minutes = mins
        @seconds = secs
      end

      class <<self

        def create_from_string(asc_time)
          (mins, secs) = asc_time.split(':')
          new(mins.to_i, secs.to_f)
        end

        def create_from_seconds(secs)
          ms = (secs.to_f / 60.0).floor
          ss = secs.to_f - ms.minutes.to_f
          new(ms, ss)
        end

        def create_from_length(cm, speed)
          secs = cm.to_f / speed.to_f
          create_from_seconds(secs)
        end

      end

      def to_sec
        return self.minutes.minutes + self.seconds
      end

      def -(other)
        return self.class.create_from_seconds(self.to_sec - other.to_sec)
      end

      def +(other)
        return self.class.create_from_seconds(self.to_sec + other.to_sec)
      end

      def to_s
        return to_common_s("%02d:%05.2f", self.seconds)
      end

      def to_mp3splt
        return to_common_s("%02d.%05.2f", self.seconds)
      end

      def to_mp3splt_output_suffix
        s_string = calculate_seconds_string
        return to_common_s("%02dm_%s", s_string)
      end

      def to_cm(speed)
        return speed * self.to_sec
      end

    private

      def to_common_s(format, s)
        return format % [ self.minutes, s ]
      end

      def calculate_seconds_string
        r_string = ''
        secs = self.seconds.floor
        frac = self.seconds - secs
        frac = (frac * 100.00).round
        div = frac / 100
        rem = frac % 100
        secs += div
        if rem > 0
          r_string = "%02ds_%02dh" % [ secs, rem ]
        else
          r_string = "%02ds" % [ secs ]
        end
        r_string
      end

    end

  end

end
