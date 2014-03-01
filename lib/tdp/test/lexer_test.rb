#
# $Id: lexer_test.rb 369 2009-04-17 03:40:30Z nicb $
#
require File.dirname(__FILE__) + '/../lexer'

class LexerTester

  attr_accessor :yydebug

  include Lexer

  def initialize
    @yydebug = true
  end

end

l = LexerTester.new
l.lexer('Sessione di riversamento'.chomp)
l.lexer('Bernardini, Quaresima'.chomp)
l.lexer("\n".chomp)
l.lexer("\t   ".chomp)

fh = File.open(File.dirname(__FILE__) + '/../note.txt')
while line = fh.gets
  l.lexer(line.chomp)
end
fh.close
