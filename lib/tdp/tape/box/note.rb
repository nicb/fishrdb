#
# $Id: note.rb 502 2010-05-30 20:56:50Z nicb $
#

require 'calligraphy_description'

module Tdp

  module Box

    class Note

      attr_accessor :lines, :calligraphy

      def initialize
        @lines = ''
        @calligraphy = nil
      end

      #
			# Tape Box Parser recognizes (and converts the following special tokens):
			# 
			# LPAR            -> '('
			# RPAR            -> ')'
			# __LBRACE__      -> '{'
			# __RBRACE__      -> '}'
			# __BLANK_LINE__  -> '\n'
      #
      NOTE_CONVERSIONS =
      [
        [ /LPAR\s+/, '(' ],
        [ /\s+RPAR/, ')' ],
        [ /__LBRACE__\s+/, '{' ],
        [ /\s+__RBRACE__/, '}' ],
        [ /__BLANK_LINE__/, "\n" ],
      ]

      def lines=(string)
        cvt_string = string.dup
        NOTE_CONVERSIONS.each do
          |conv|
          cvt_string = cvt_string.gsub(conv[0], conv[1])
        end
        @lines += cvt_string
      end

    end

  end

end
