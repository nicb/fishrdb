#
# $Id: duration.rb 596 2011-01-03 08:50:36Z nicb $
#
# This class requires the following software to be installed on the host
# system:
#
# - mp3check (for Mp3Duration::create_from_mp3_file)
#

module Mp3Helper

  class Duration < Time
    
    TIME_SEWED_IN_YEAR  = 0
    TIME_SEWED_IN_MONTH = 1
    TIME_SEWED_IN_DAY   = 1
    USEC_MULTIPLIER = 1000000.0
    HUN_MULTIPLIER  = 100.0
    HUN_DIVISOR = (USEC_MULTIPLIER / HUN_MULTIPLIER)
    MS_MAX = 60.0
    SECS_IN_HOUR = 3600.0

    private_class_method :new

    class <<self

      def local(h, m, s, usec = 0)
        super(TIME_SEWED_IN_YEAR, TIME_SEWED_IN_MONTH, TIME_SEWED_IN_DAY,
                h, m, s, usec)
      end

      def create_from_mp3check_string(string)
        (h, m, s_h) = string.split(':')
        s_h = s_h.to_f
        sec = s_h.floor
        usec = ((s_h - sec) * USEC_MULTIPLIER).round
        local(h, m, sec, usec)
      end

      def create_from_mp3splt_string(string)
        (m, s, frac) = string.split('.')
        m = m.to_i
        h = (m.to_f / MS_MAX).floor
        m %= MS_MAX
        usec = ((frac.to_f/frac_divisor(frac)) * USEC_MULTIPLIER).round
        local(h, m, s, usec)
      end

      def create_from_seconds(num)
        h = (num.to_f / 3600.0).floor
        rem = (num.to_f % 3600.0)
        m = (rem.to_f / 60.0).floor
        sec = (rem.to_f % 60.0)
        usec = ((sec - sec.floor) * USEC_MULTIPLIER).round
        local(h, m, sec, usec)
      end

      def create_from_mp3_file(file) # this requires mp3check
        val = nil
        syscall = "mp3check -l \"#{file}\" | tail -1 | cut -d ' ' -f 15"
        res = IO::popen(syscall) { |f| val = f.gets.chomp }
        raise(SystemCallFailure, "mp3check call failed for file #{file}") unless res
        create_from_mp3check_string(val)
      end

    private

      def frac_divisor(frac)
        10**(frac.size)
      end

    end

    def to_s
      "%02d:%02d:%02d.%02d" % [ self.hour, self.min, self.sec, hun ]
    end

    def to_minutes_and_seconds
      mins = (self.hour * 60) + self.min
      "%d.%02d.%02d" % [ mins, self.sec, hun ]
    end

    def to_seconds
      (self.hour * SECS_IN_HOUR) + (self.min * MS_MAX) + self.sec + frac_usec
    end

    def +(other)
      Duration.create_from_seconds(self.to_seconds + other.to_seconds)
    end

    def -(other)
      Duration.create_from_seconds(self.to_seconds - other.to_seconds)
    end

  private

    def hun
      (self.usec / HUN_DIVISOR).floor
    end

    def frac_usec
      (self.usec / USEC_MULTIPLIER)
    end

  end

end
