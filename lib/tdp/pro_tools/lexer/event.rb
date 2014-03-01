#
# $Id: event.rb 586 2010-12-20 00:15:47Z nicb $
#
require File.join(File.dirname(__FILE__), '..', 'session_time')

module Tdp

  module ProTools

    module Lexer

	    class Event
	
	      attr_reader :channel, :event, :region_name, :start_time, :end_time, :duration
	
	      def initialize(ch, evno, rname, st, et, dur)
	        @channel = ch
	        @event   = evno
	        @region_name = rname
	        @start_time = ::Tdp::ProTools::SessionTime.create_from_string(st)
	        @end_time = ::Tdp::ProTools::SessionTime.create_from_string(et)
	        @duration = ::Tdp::ProTools::SessionTime.create_from_string(dur)
	      end
	      
	      class << self
	
	        def create_from_line(line)
	          (ch, evno, rname, st, et, dur) = line.split(/\t\s*/)
	          new(ch, evno, rname, st, et, dur)
	        end

        private
	
	      end
	
	    end

    end

  end

end
