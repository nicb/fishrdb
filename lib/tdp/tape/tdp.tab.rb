#
# DO NOT MODIFY!!!!
# This file is automatically generated by racc 1.4.5
# from racc grammer file "tdp.racc".
#

require 'racc/parser'


#
# $Id: tdp.racc 491 2010-04-18 01:53:37Z nicb $
#

require File.dirname(__FILE__) + '/../tape'

require 'yaml'

class DescriptionTapeParseError < StandardError
end


module Tdp

  module Tape

    class DescriptionParser < Racc::Parser

module_eval <<'..end tdp.racc modeval..ide93f7cafd6', 'tdp.racc', 98

  attr_accessor :tape, :line, :yydebug, :result, :id_tag

  require 'lexer'

  include Tdp::Tape::Lexer

  def initialize(tape, debug = false)
    @tape = tape
    @line = 1
    @yydebug = debug
    @result = {}
    @id_tag = ''
  end

  def parse(one_line)
    begin
        result = tdp_lexer(one_line, :bump_line) { do_parse }
    rescue ParseError
        raise ParseError.new("Tape Description failed at line #{line}: #{$!}")
    end
    return result
  end

  def next_token
    @q.shift
  end

  def bump_line(inc = 1)
    self.line += inc
  end

..end tdp.racc modeval..ide93f7cafd6

##### racc 1.4.5 generates ###

racc_reduce_table = [
 0, 0, :racc_error,
 3, 26, :_reduce_1,
 11, 27, :_reduce_2,
 4, 30, :_reduce_3,
 3, 30, :_reduce_4,
 1, 30, :_reduce_5,
 2, 29, :_reduce_6,
 2, 32, :_reduce_7,
 2, 32, :_reduce_8,
 1, 32, :_reduce_9,
 4, 31, :_reduce_10,
 3, 33, :_reduce_11,
 2, 33, :_reduce_12,
 1, 33, :_reduce_none,
 1, 34, :_reduce_none,
 1, 34, :_reduce_none,
 1, 34, :_reduce_none,
 1, 34, :_reduce_none,
 1, 34, :_reduce_none,
 2, 35, :_reduce_none,
 1, 35, :_reduce_none,
 1, 35, :_reduce_none,
 1, 35, :_reduce_none,
 1, 35, :_reduce_none,
 1, 35, :_reduce_none,
 1, 35, :_reduce_none,
 1, 35, :_reduce_none,
 1, 35, :_reduce_none,
 1, 35, :_reduce_none,
 2, 28, :_reduce_none,
 1, 28, :_reduce_none ]

racc_reduce_n = 31

racc_shift_n = 52

racc_action_table = [
    18,    21,    23,    24,    26,    28,    29,    30,     9,    45,
    47,    46,    22,    48,    25,    27,     3,     6,    13,    32,
    15,    11,    19,    18,    21,    23,    24,    26,    28,    29,
    30,    33,     8,    35,    14,    22,    38,    25,    27,    39,
    40,     7,    11,    15,    41,    19,    18,    21,    23,    24,
    26,    28,    29,    30,    42,    43,     6,     4,    22,    49,
    25,    27,    50,    51,   nil,   nil,    15,   nil,    19,    18,
    21,    23,    24,    26,    28,    29,    30,   nil,   nil,   nil,
   nil,    22,   nil,    25,    27,   nil,   nil,   nil,   nil,    15,
   nil,    19 ]

racc_action_check = [
    31,    31,    31,    31,    31,    31,    31,    31,     5,    44,
    45,    44,    31,    45,    31,    31,     0,    31,     7,    13,
    31,     5,    31,    12,    12,    12,    12,    12,    12,    12,
    12,    14,     4,    20,     9,    12,    32,    12,    12,    33,
    34,     3,    37,    12,    38,    12,    16,    16,    16,    16,
    16,    16,    16,    16,    41,    42,     2,     1,    16,    46,
    16,    16,    48,    49,   nil,   nil,    16,   nil,    16,    36,
    36,    36,    36,    36,    36,    36,    36,   nil,   nil,   nil,
   nil,    36,   nil,    36,    36,   nil,   nil,   nil,   nil,    36,
   nil,    36 ]

racc_action_pointer = [
     6,    57,    37,    25,    32,     2,   nil,     7,   nil,    18,
   nil,   nil,    21,     3,    16,   nil,    44,   nil,   nil,   nil,
    16,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    -2,    24,    36,    20,   nil,    67,    23,    28,   nil,
   nil,    47,    42,   nil,     7,    -3,    56,   nil,    49,    43,
   nil,   nil ]

racc_action_default = [
   -31,   -31,   -31,   -31,   -31,   -31,   -30,   -31,    52,   -31,
    -1,   -29,   -31,   -31,   -31,   -16,    -9,   -13,   -27,   -18,
   -15,   -28,   -14,   -22,   -24,   -17,   -25,   -20,   -21,   -23,
   -26,    -6,   -31,   -31,   -12,   -19,    -7,    -8,   -31,   -10,
   -11,   -31,   -31,    -5,   -31,   -31,   -31,    -4,   -31,   -31,
    -3,    -2 ]

racc_goto_table = [
     5,    34,    44,    16,    10,    12,    31,     2,     1,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,    34,    36,   nil,   nil,   nil,   nil,   nil,   nil,    37 ]

racc_goto_check = [
     3,     9,     5,     8,     4,     6,     7,     2,     1,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,     9,     8,   nil,   nil,   nil,   nil,   nil,   nil,     3 ]

racc_goto_pointer = [
   nil,     8,     7,    -2,    -1,   -40,     0,    -6,    -9,   -15,
   nil ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    17,
    20 ]

racc_token_table = {
 false => 0,
 Object.new => 1,
 :COMMA => 2,
 :COLON => 3,
 :RPAR => 4,
 :RSQ => 5,
 :DASH => 6,
 :LPAR => 7,
 :LSQ => 8,
 :EQ => 9,
 :SESSION_HEADER => 10,
 :DATE => 11,
 :LOCATION => 12,
 :TRANSFERRER => 13,
 :ANYWORD => 14,
 :TAPE_TAG => 15,
 :WHITE_SPACE => 16,
 :PUNCTUATION => 17,
 :ID_TAG => 18,
 :EMPTY_LINE => 19,
 :EOL => 20,
 :TAPE_CONTENT_HEADER => 21,
 :TAPE_SEGMENT => 22,
 :DOLLAR => 23,
 :AUTHOR_INITIALS => 24 }

racc_use_result_var = true

racc_nt_base = 25

Racc_arg = [
 racc_action_table,
 racc_action_check,
 racc_action_default,
 racc_action_pointer,
 racc_goto_table,
 racc_goto_check,
 racc_goto_default,
 racc_goto_pointer,
 racc_nt_base,
 racc_reduce_table,
 racc_token_table,
 racc_shift_n,
 racc_reduce_n,
 racc_use_result_var ]

Racc_token_to_s_table = [
'$end',
'error',
'COMMA',
'COLON',
'RPAR',
'RSQ',
'DASH',
'LPAR',
'LSQ',
'EQ',
'SESSION_HEADER',
'DATE',
'LOCATION',
'TRANSFERRER',
'ANYWORD',
'TAPE_TAG',
'WHITE_SPACE',
'PUNCTUATION',
'ID_TAG',
'EMPTY_LINE',
'EOL',
'TAPE_CONTENT_HEADER',
'TAPE_SEGMENT',
'DOLLAR',
'AUTHOR_INITIALS',
'$start',
'desc',
'session_head',
'empty_lines',
'tape',
'transferrers',
'tape_header',
'tape_description',
'filled_line',
'word',
'punctuation']

Racc_debug_parser = false

##### racc system variables end #####

 # reduce 0 omitted

module_eval <<'.,.,', 'tdp.racc', 16
  def _reduce_1( val, _values, result )
 tape.session = val[0]; tape.description = val[2]; result = tape
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 27
  def _reduce_2( val, _values, result )
                session = Tdp::Tape::SessionDescription.new
                session.date = val[2]
                session.location = val[4]
                session.transferrers = val[7]
                result = session
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 29
  def _reduce_3( val, _values, result )
 result << Tdp::Tape::SessionDescription.map_transferrer(val[3])
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 30
  def _reduce_4( val, _values, result )
 result << Tdp::Tape::SessionDescription.map_transferrer(val[2])
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 31
  def _reduce_5( val, _values, result )
 result = [ Tdp::Tape::SessionDescription.map_transferrer(val[0]) ]
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 40
  def _reduce_6( val, _values, result )
            t_desc = val[0]
            t_desc.description = val[1].chomp
            result = t_desc
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 42
  def _reduce_7( val, _values, result )
 result = val[0..1].join
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 43
  def _reduce_8( val, _values, result )
 result = val[0..1].join
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 44
  def _reduce_9( val, _values, result )
 result = val[0].strip.chomp
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 53
  def _reduce_10( val, _values, result )
            t_description = Tdp::Tape::TapeDescription.new
            t_description.tag = val[2]
            result = t_description
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 55
  def _reduce_11( val, _values, result )
 result = val[0..3].join.chomp
   result
  end
.,.,

module_eval <<'.,.,', 'tdp.racc', 56
  def _reduce_12( val, _values, result )
 result = val[0..2].join
   result
  end
.,.,

 # reduce 13 omitted

 # reduce 14 omitted

 # reduce 15 omitted

 # reduce 16 omitted

 # reduce 17 omitted

 # reduce 18 omitted

 # reduce 19 omitted

 # reduce 20 omitted

 # reduce 21 omitted

 # reduce 22 omitted

 # reduce 23 omitted

 # reduce 24 omitted

 # reduce 25 omitted

 # reduce 26 omitted

 # reduce 27 omitted

 # reduce 28 omitted

 # reduce 29 omitted

 # reduce 30 omitted

 def _reduce_none( val, _values, result )
  result
 end

    end   # class DescriptionParser

  end   # module Tape

end   # module Tdp

#
# test code - to be commented out in production
#
#
# tdp = Tape::DescriptionParser.new(true)
# fh = File.open(ARGV[0], 'r')
# one_line = fh.gets
# session = tdp.parse(one_line)
# $stderr.puts("Session: #{session.inspect}")
