#
# $Id: lexer.rb 494 2010-05-02 03:39:44Z nicb $
#

module Tdp

  module Tape
  
    module Lexer

      class StringFifo < Array

        MAX_LAST_PUSHED = 10

        def last_pushed
          lp = self.size > MAX_LAST_PUSHED ? MAX_LAST_PUSHED : self.size
          self[-lp..-1].join
        end

      end
    
      def input_conditioner(fh)
        result = ''
        while line = fh.gets
          result += line.sub(/^\s*$/, '@==@').sub(/\n/, '@@')
        end
        return result
      end
    
      def info(msg)
        $stderr.puts(msg) if @lexdebug == true
      end
    
      def tdp_lexer(str, bump_line_method, debug = false, &block)
        @q = []
        @last_fragments = StringFifo.new
        @lexdebug = debug
        info("lexing: \"#{str}\"")
        until str.empty?
          #info("remaining string: \"#{str}\"")
          @last_fragments.push(@q.last ? @q.last[1] : '')
          case str
          when /^Sessione di riversamento/
            @q.push [:SESSION_HEADER, $&]
            info(":SESSION_HEADER: #{$&}")
          when /\A[0-3]?[0-9]\/[0-1]?[0-9]\/\d{4}/
            @q.push [:DATE, $&]
            info(":DATE: #{$&}")
          when /\A(Studio Schiavoni|Discoteca di Stato)/
            @q.push [:LOCATION, $&]
            info(":LOCATION: #{$&}")
          when /\A(Bernardini|Quaresima|Cursi|Schiavoni|Gianni)/
            @q.push [:TRANSFERRER, $&]
            info(":TRANSFERRER: #{$&}")
          when /\ANastro\s+NM[AG][AS]\d{4}-\w{1,5}/
            @q.push [:TAPE_TAG, $&]
            info(":TAPE_TAG: #{$&} - #{@q.inspect}")
          when /\A[AB]\d{2,}/
            @q.push [:TAPE_SEGMENT, $&]
            info(":TAPE_SEGMENT: #{$&}")
          when /\A@==@/                                 # this is an empty line
            @q.push [:EMPTY_LINE, "\n"]
            info(":EMPTY_LINE: #{$&}")
            send(bump_line_method, 2)
          when /\A@{2}/                                   # this is an end of line
            @q.push [:EOL, "\n"]
            info(":EOL: #{$&}")
            send(bump_line_method)
          #
          # significant punctuation must be treated separately
          #
          when /\A\(/
            @q.push [:LPAR, $&]
            info("LPAR -> #{$&}: #{$&}")
          when /\A\)/
            @q.push [:RPAR, $&]
            info("RPAR -> #{$&}: #{$&}")
          when /\A,/
            @q.push [:COMMA, $&]
            info("COMMA -> #{$&}: #{$&}")
          when /\A:/
            @q.push [:COLON, $&]
            info("COLON -> #{$&}: #{$&}")
          when /\A\[/
            @q.push [:LSQ, $&]
            info("LSQ -> #{$&}: #{$&}")
          when /\A\]/
            @q.push [:RSQ, $&]
            info("RSQ -> #{$&}: #{$&}")
          when /\A-/
            @q.push [:DASH, $&]
            info("DASH -> #{$&}: #{$&}")
          when /\A\$/
            @q.push [:DOLLAR, $&]
            info("DOLLAR -> #{$&}: #{$&}")
          when /\A=/
            @q.push [:EQ, $&]
            info("EQ -> #{$&}: #{$&}")
          #
          # any other punctuation is not significant for parsing and goes here
          #
          when /\A[;.\/!?`'"*\|%<>]/
            @q.push [:PUNCTUATION, $&]
            info("PONCTUATION -> #{$&}: #{$&}")
          when /\A[àèìòùéüêçÇäöÈáóčćŽôÀÂŰ+\w]+/
            @q.push [:ANYWORD, $&]
            info(":ANYWORD: #{$&}")
          when /\A\s+/                                # eat white space
            @q.push [:WHITE_SPACE,' ']
            info(":WHITE_SPACE: #{$&}")
          end
          if $'
            str = $'
          else
            raise StandardError.new("Lexer: could not match \"#{str[0..20]}...\"")
          end
        end
        @q.push [false, '$end']
        yield if block_given?
      end
      
      def tcp_lexer(str, bump_line_method, debug = false, &block)
        @q = []
        @lexdebug = debug
        @last_fragments = StringFifo.new
        info("lexing: \"#{str}\"")
        until str.empty?
          #info("remaining string: \"#{str}\"")
          @last_fragments.push(@q.last ? @q.last[1] : '')
          case str
#          when /\A\[[AB]\d{2,}(-[AB]\d{2,})?\]/
#           @q.push [:TAPE_CONTENT_TAG, $&]
#           info(":TAPE_CONTENT_TAG: #{$&}")
          when /\A[AB]\d{2,}/
            @q.push [:TAPE_SEGMENT, $&]
            info(":TAPE_SEGMENT: #{$&}")
          when /\AIl nastro contiene:\s*/
            @q.push [:TAPE_CONTENT_HEADER, $&]
            info(":TAPE_CONTENT_HEADER: #{$&}")
          when /\A@==@/                                 # this is an empty line
            @q.push [:EMPTY_LINE, "\n"]
            info(":EMPTY_LINE: #{$&}")
            send(bump_line_method, 2)
          when /\A@{2}/                                   # this is an end of line
            @q.push [:EOL, "\n"]
            info(":EOL: #{$&}")
            send(bump_line_method)
          #
          # significant punctuation must be treated separately
          #
          when /\A\(/
            @q.push [:LPAR, $&]
            info("LPAR -> #{$&}: #{$&}")
          when /\A\)/
            @q.push [:RPAR, $&]
            info("RPAR -> #{$&}: #{$&}")
          when /\A,/
            @q.push [:COMMA, $&]
            info("COMMA -> #{$&}: #{$&}")
          when /\A:/
            @q.push [:COLON, $&]
            info("COLON -> #{$&}: #{$&}")
          when /\A\[/
            @q.push [:LSQ, $&]
            info("LSQ -> #{$&}: #{$&}")
          when /\A\]/
            @q.push [:RSQ, $&]
            info("RSQ -> #{$&}: #{$&}")
          when /\A-/
            @q.push [:DASH, $&]
            info("DASH -> #{$&}: #{$&}")
          when /\A\$/
            @q.push [:DOLLAR, $&]
            info("DOLLAR -> #{$&}: #{$&}")
          when /\A=/
            @q.push [:EQ, $&]
            info("EQ -> #{$&}: #{$&}")
          #
          # any other punctuation is not significant for parsing and goes here
          #
          when /\A[;.\/!?`'"*+|]/
            @q.push [:PUNCTUATION, $&]
            info("PONCTUATION -> #{$&}: #{$&}")
          when /\A[àèìòùéüêçÇöÈáóčćŽôÀÂŰ\w]+/
            @q.push [:ANYWORD, $&]
            info(":ANYWORD: #{$&}")
          when /\A\s+/                                # eat white space
            @q.push [:WHITE_SPACE, ' ']
            info(":WHITE_SPACE: #{$&}")
          end
          if $'
            str = $'
          else
            raise StandardError.new("Lexer: could not match \"#{str[0..20]}...\"")
          end
        end
        @q.push [false, '$end']
        yield if block_given?
      end

      def tbp_lexer(str, bump_line_method, debug = false, &block)
        @q = []
        @lexdebug = debug
        @last_fragments = StringFifo.new
        info("lexing: \"#{str}\"")
        until str.empty?
          #info("remaining string: \"#{str}\"")
          @last_fragments.push(@q.last ? @q.last[1] : '')
          case str
          when /\AIl nastro contiene:/
            @q.push [:TAPE_CONTENT_HEADER, $&]
            info(":TAPE_CONTENT_HEADER: #{$&}")
          when /\A\s+Il\s+presunto\s+contenitore\s+(contiene|reca)\s+le\s+seguenti\s+scritte:/
            @q.push [:TAPE_BOX_HEADER, $&]
            info(":TAPE_BOX_HEADER: #{$&}")
          when /\A(@==@)+\s{2,}\([\w\d'\-\s,\.]+\)\s*@@/
            @q.push [:DISPLAY_LOCATION, $&]
            info(":DISPLAY_LOCATION: #{$&}")
          when /\A\s+====\s*@@/
            @q.push [:DISPLAY_TERM_SEPARATOR, $&]
            info(":DISPLAY_TERM_SEPARATOR: #{$&}")
          when /\A\s*nessuna[.]?\s*@@/
            @q.push [:NO_DISPLAYS, $&]
            info(":NO_DISPLAYS: #{$&}")
          when /\Acalligrafia/
            @q.push [:CALLIGRAPHY, $&]
            info(":CALLIGRAPHY: #{$&}")
          when /\A[A-Z?]{2,}\)\s*/
            @q.push [:AUTHOR_INITIALS, $&]
            info(":AUTHOR_INITIALS: #{$&}")
            send(bump_line_method)
          when /\A\?{2,}/
            @q.push [:QUESTION_MARKS, $&]
            info(":QUESTION_MARKS: #{$&}")
          when /\A\?/
            @q.push [:QUESTION_MARK, $&]
            info(":QUESTION_MARK: #{$&}")
#         when /\A[AB]\d{2,}(BIS)*/
#           @q.push [:TAPE_SEGMENT, $&]
#           info(":TAPE_SEGMENT: #{$&}")
          when /\A\$Id:/
            @q.push [:ID_TAG, $&]
            info(":ID_TAG: #{$&}")
          when /\A\s*@==@/                                # this is an empty line
            @q.push [:EMPTY_LINE, "\n"]
            info(":EMPTY_LINE: #{$&}")
            send(bump_line_method, 2)
          when /\A@{2}/                                   # this is an end of line
            @q.push [:EOL, "\n"]
            info(":EOL: #{$&}")
            send(bump_line_method)
          #
          # significant punctuation must be treated separately
          #
          when /\A\(/
            @q.push [:LPAR, $&]
            info("LPAR -> #{$&}: #{$&}")
          when /\A\)/
            @q.push [:RPAR, $&]
            info("RPAR -> #{$&}: #{$&}")
          when /\A,/
            @q.push [:COMMA, $&]
            info("COMMA -> #{$&}: #{$&}")
          when /\A:/
            @q.push [:COLON, $&]
            info("COLON -> #{$&}: #{$&}")
          when /\A\[/
            @q.push [:LSQ, $&]
            info("LSQ -> #{$&}: #{$&}")
          when /\A\]/
            @q.push [:RSQ, $&]
            info("RSQ -> #{$&}: #{$&}")
          when /\A-/
            @q.push [:DASH, $&]
            info("DASH -> #{$&}: #{$&}")
          when /\A\$/
            @q.push [:DOLLAR, $&]
            info("DOLLAR -> #{$&}: #{$&}")
          when /\A=/
            @q.push [:EQ, $&]
            info("EQ -> #{$&}: #{$&}")
          when /\A\{/
            @q.push [:LBRACE, $&]
            info("LBRACE -> #{$&}: #{$&}")
          when /\A\}/
            @q.push [:RBRACE, $&]
            info("RBRACE -> #{$&}: #{$&}")
          #
          # any other punctuation is not significant for parsing and goes here
          #
          when /\A[;.\/!?`'"*\|><+\^±\\#]/
            @q.push [:PUNCTUATION, $&]
            info("PONCTUATION -> #{$&}: #{$&}")
          when /\A[àèìòùéüêçÈáóčćŽôÀÂŰ\w]+/
            @q.push [:ANYWORD, $&]
            info(":ANYWORD: #{$&}")
          when /\A\s+/                                # eat white space
            @q.push [:WHITE_SPACE, ' ']
            info(":WHITE_SPACE: #{$&}")
          end
          if $'
            str = $'
          else
            raise StandardError.new("Lexer: could not match \"#{str[0..20]}...\"")
          end
        end
        @q.push [false, '$end']
        yield if block_given?
      end
    
    end
  
  end

end
