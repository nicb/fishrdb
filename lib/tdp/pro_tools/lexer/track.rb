#
# $Id: track.rb 587 2010-12-20 02:22:37Z nicb $
#
module Tdp

	module ProTools

    module Lexer

		class TrackHeaderLine

		  attr_reader :header, :value_setter_method, :default_value, :optional

		  def initialize(h, v = nil, opt = false, dv = nil)
			@header = h
			@value_setter_method = v
            @optional = opt
            @default_value = dv
          end

          def optional?
            self.optional
          end

        end

	    class Track < SectionParser
	
	      attr_accessor :events, :name, :user_delay
	
	      def initialize(fh)
	        @events = []
	        super(fh)
	      end
	
	      def parse(line = '')
	        line = parse_headers(line)
	        line = parse_lines(line)
	      end
	
	    private
	
	      TRACK_HEADER_LINES =
          [
            TrackHeaderLine.new('TRACK NAME:', :name),
            TrackHeaderLine.new('USER DELAY:', :user_delay, true, '0 Samples'),
            TrackHeaderLine.new('CHANNEL	EVENT	REGION NAME	START TIME	END TIME	DURATION'),
          ]
				
	      def parse_headers(line)

	        TRACK_HEADER_LINES.each do
	          |thl|
              if thl.optional? && line !~ /^#{thl.header}/
	            set_value(thl.value_setter_method, thl.default_value) if thl.value_setter_method
                next
              end
	          raise(WrongSectionHeader, "(#{self.line_number.n}): expecting ~ \"#{thl.header}\" but got \"#{line}\"") unless line =~ /^#{thl.header}/
	          set_value(thl.value_setter_method, line) if thl.value_setter_method
	          line = self.readline
	        end
	
	        line
	      end
	
	      def parse_lines(line)
	
	        while(line && line !~ /^#{TRACK_HEADER_LINES.first.header}/)
	          self.events << Event.create_from_line(line) unless line.blank?
	          line = self.readline
	        end
	
	        line
	      end
	
	    end

    end

  end

end
