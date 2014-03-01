#
# $Id: exceptions.rb 584 2010-12-19 22:12:55Z nicb $
#
require File.join(File.dirname(__FILE__), '..', 'exceptions')

module Tdp

  module ProTools

    module Lexer

	    class PureVirtualMethodCalled < StandardError; end

	    class LexicalError < ::Tdp::ProTools::CatchableException; end
	    class WrongSectionHeader < ::Tdp::ProTools::CatchableException; end

    end

  end

end
