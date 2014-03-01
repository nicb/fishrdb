#
# $Id: old_data_aggregator.rb 588 2010-12-23 15:44:27Z nicb $
#

pts_cwd = File.dirname(__FILE__)
require pts_cwd + '/old_lexer'

module Tdp

  module ProTools

    class OldSessionTime < Time

      class << self

        private_class_method :new

	      def create(asc_time)
	        (minutes, frac_seconds) = asc_time.split(':')
	        (seconds, milliseconds) = frac_seconds.split('.')
	        minutes = minutes.to_i
	        hours = (minutes / 60).to_i
	        minutes = (minutes % 60).to_i
	        usecs = milliseconds.to_i * 1000
	        result = local(0, 1, 1, hours, minutes, seconds.to_i, usecs)
	        return result
	      end

      end

      def to_sec
        return ((hour * 3600) + (min * 60) + sec + (usec/1000000)).to_f
      end


    end

    class OldTrack
      attr_accessor :regions, :channel, :cm_cache, :tape_length

      class << self

        def extract_track_channel(line)
          return line.sub(/\A.*CH\s+([0-9]+).*\Z/, '\1').to_i
        end

      end

      def initialize(lexed_line, tl)
        @channel = self.class.extract_track_channel(lexed_line)
        @regions = []
        @cm_cache = 0
        @tape_length = tl
      end

      def <<(region)
        region.original_position_on_tape_in_cm = cm_cache
        @cm_cache += region.to_cm
        @cm_cache = 0 if @cm_cache >= tape_length
        regions << region
      end

    end

    class OldRegion
      attr_reader :name, :reference, :speed, :tape_direction 
      attr_accessor :num_channels, :event_num, :start_time, :end_time, :duration, :original_position_on_tape_in_cm

      def initialize(lexed_line)
        (@name, @reference) = lexed_line.chomp('||').split(/\t\s*/)
        @reference = 'Riv' + @reference
        @speed = self.class.extract_speed(@name)
        dir = @name.index('REV')
        @tape_direction = dir ? :REVERSE : :STRAIGHT
        @original_position_on_tape_in_cm = 0
      end

      class << self

        def extract_speed(region_name)
          return region_name.sub(/\A.*@([0-9,]+).*\Z/, '\1').sub(/,/, '.').to_f
        end

        def extract_data_parameters(lexed_line)
          a = lexed_line.chomp('||').split(/\t\s*/)
          result =
          {
            :num_channels => a[0].to_i,
            :event_num => a[1].to_i,
            :region => a[2],
            :start_time => OldSessionTime.create(a[3]),
            :end_time => OldSessionTime.create(a[4]),
          }
          return result
        end

        def calculate_full_tape_length(attributes)
          speed = extract_speed(attributes[:region])
          result = attributes[:end_time].to_sec * speed
          return result
        end

      end

      def add_track_data(attribs)
        data = attribs.dup
        data.delete(:region)
        data.each do
          |k, v|
          send(k.to_s + '=', v)
        end
      end

      def to_cm
        return (end_time - start_time) * speed
      end

    end

    class OldRegionNotFound < StandardError
    end

    class OldDataAggregator

      attr_reader :filename
      attr_accessor :regions, :tracks, :line_number, :tape_length_cache

      def initialize(f)
        @filename = f
        @tracks = []
        @regions = []
        @line_number = 0
        @tape_length_cache = 0
      end

      def find_region(region)
        result = nil
        regions.each do
          |fr| 
          if fr.name == region
            result = fr
            break
          end
        end
        raise OldRegionNotFound.new("Region \"#{region}\" not found") unless result
        return result
      end

      def do_parse(buffer)
        buffer.each do
          |el|
          case el[0]
          when :REGION
            regions << OldRegion.new(el[1])
          when :TRACK
            tracks << OldTrack.new(el[1], tape_length_cache)
          when :TRACK_ITEM 
            attribs = OldRegion.extract_data_parameters(el[1])
            r = find_region(attribs[:region])
            r.add_track_data(attribs)
            tracks.last << r
          when :TRACK_INFO
            attribs = OldRegion.extract_data_parameters(el[1])
            @tape_length_cache = OldRegion.calculate_full_tape_length(attribs)
          end
        end
      end

      def parse
        l = Tdp::ProTools::OldLexer.new
        fh = File.open(filename, 'r')
        one_line = l.input_conditioner(fh)
        l.lexer(one_line) { |b| do_parse(b) }
        fh.close
      end

    end

  end

end
