#
# $Id: old_lexer.rb 588 2010-12-23 15:44:27Z nicb $
#

module Tdp

	module ProTools
	
		module OldLexerMethods

      attr_reader   :lexdebug
      attr_accessor :line_number, :queue

      def initialize_instance_variables(dbg = false)
        @lexdebug = dbg
        @line_number = 0
      end

      def bump_line(val = 1)
        return @line_number += val
      end

		  def input_conditioner(fh)
		    result = ''
		    while line = fh.gets
		      result += line.sub(/^\s*$/, '|==|').sub(/\n/, '||')
		    end
		    return result
		  end
		
		  def info(msg)
		    $stderr.puts("Line #{line_number}: " + msg + "\n") if lexdebug == true
		  end
		
			def lexer(str, &block)
			  @queue = []
        context = :no_context
			  until str.empty?
          if context == :no_context
            #
	          # region context selection goes first
	          #
	          str =~ /\A.*R E G I O N S  I N  S E S S I O N\|\|REGION NAME\s+Source File\|\|/
	          context = :regions
						info("Entering context #{context.to_s}")
            bump_line(3)
            str = $'
          end

          if context == :regions
            case str
	          #
	          # actual lexical items for REGIONS
	          #
	          when /\A[AB][0-9]{2,}(BIS|TER)?@[0-9,.]+(REV|-[0-9]+|\.[LR]|[\sA-Za-z0-9])?\s+[^|]*\.aif\|\|/
				      queue.push [:REGION, $&]
							info(":REGION: #{$&}")
              bump_line
            when /\AT R A C K  L I S T I N G\|\|/
	            context = :tracks
							info("switching to #{context} context")
              bump_line
            when /\A[^|]*\|\|/
              #
              # skip anything else in the middle...
              #
              bump_line
            when /\A(\|==\|)+/
              #
              # ...including blank lines
              #
              bump_line
            end
          elsif context == :tracks || context == :track_items || context == :track_info
            case str
	          #
	          # actual lexical items for TRACK ITEMS
	          #
	          when /\A[0-9]+\s+[0-9]+[^|]*\|\|/
              tag = context == :track_items ? :TRACK_ITEM : :TRACK_INFO
				      queue.push [tag, $&]
							info("#{tag.to_s}: #{$&}")
              bump_line
            when /\ATRACK NAME: Riv@[0-9,]+ (Stereo)\|\|USER DELAY: 0 Samples\|\|CHANNEL EVENT REGION NAME START TIME  END TIME  DURATION\|\|/
              context = :track_info
							info(":TRACK: (in track context - switching to track info context) #{$&}")
              bump_line(4)
	          when /\ATRACK NAME:\s+CH\s+[0-9]+\|\|USER DELAY:\s+0 Samples\|\|CHANNEL\s+EVENT\s+REGION NAME\s+START TIME\s+END TIME\s+DURATION\|\|/
              context = :track_items
              queue.push [:TRACK, $&]
							info(":TRACK: (in track context - switching to track item context) #{$&}")
              bump_line(4)
            when /\A[^|]*\|\|/
              #
              # skip anything in the middle...
              #
              context = :tracks
              bump_line
            when /\A(\|==\|)+/
              #
              # ... including empty lines (and go back to tracks)
              #
              context = :tracks
              bump_line
	          end
          end
		      if $'
			      str = $'
		      else
            errstr = str ? str[0..30] : ''
		        raise StandardError.new("OldLexer: could not match \"#{errstr}...\"")
		      end
			  end
		    queue.push [false, '$end']
			  yield(queue) if block_given?
			end
		
		end

    class OldLexer

      include OldLexerMethods

      def initialize(dbg = false)
        initialize_instance_variables(dbg)
      end

    end
	
	end

end
