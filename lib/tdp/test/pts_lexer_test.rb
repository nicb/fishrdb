#
# $Id: pts_lexer_test.rb 493 2010-04-20 04:28:26Z nicb $
#
require File.dirname(__FILE__) + '/../pro_tools/lexer'

class LexerTester

  attr_accessor :yydebug, :line

  include Tdp::ProTools::LexerMethods

  def initialize
    initialize_instance_variables(true)
  end

end

if ARGV.size != 1
  $stderr.puts("Usage: #{$0} <file name>")
  exit(-1)
end

fh = File.open(ARGV[0], 'r')
l = LexerTester.new
one_line = l.input_conditioner(fh)
l.lexer(one_line)
fh.close
