#
# $Id: pro_tools_session.rb 585 2010-12-19 23:00:46Z nicb $
#
module Tdp

	module ProTools

    module Lexer

	    class ProToolsSession < SectionParser
	
	      attr_accessor :name, :sample_rate, :bit_depth, :time_code_format,
	        :num_of_audio_tracks, :num_of_audio_regions, :num_of_audio_files,
	        :files_in_session, :regions_in_session, :track_listing
	
	      def parse(line = '')
	        line = parse_headers
	        parse_all_contexts(line)
	      end
	
	    private
	
	      SESSION_HEADERS = [ ['SESSION NAME:', :name], ['SAMPLE RATE:', :sample_rate],
	        ['BIT DEPTH:', :bit_depth], ['TIME CODE FORMAT:', :time_code_format],
					['# OF AUDIO TRACKS:', :num_of_audio_tracks],
	        ['# OF AUDIO REGIONS:', :num_of_audio_regions],
	        ['# OF AUDIO FILES:', :num_of_audio_files] ]
	
	      def parse_headers
	        line = ''
	
	        SESSION_HEADERS.each do
	          |h|
	          line = self.file_handle.gets
              next unless line
              line.chomp!
	          raise(WrongSectionHeader, "#{self.line_number.n}: expecting ~ \"#{h[0]}\" but got \"#{line}\"") unless line =~ /^#{h[0]}/
	          set_value(h[1], line)
	          self.line_number.bump
	        end
	        line = self.readline
	        line = self.gobble_empty_lines(line)
	
	        line
	      end
	
	      def parse_all_contexts(line)
	        self.context_sequence.contexts.each do
	          |c|
	          instance = c.new(self.file_handle)
	          self.send(instance.class.name.demodulize.underscore + '=', instance)
	          line = instance.parse(line)
	          line = self.gobble_empty_lines(line)
	        end
	      end
	
	    end

    end

  end

end
