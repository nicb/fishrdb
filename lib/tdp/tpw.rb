#
# $Id: tpw.rb 376 2009-04-22 02:58:24Z nicb $
#
require File.dirname(__FILE__) + '/tape'

module Tdp

  module Tape

		class TapeParserWrapper
		
		  attr_accessor :debug, :filename, :single_line, :session
		
		private
		
		  def input_conditioner
		    result = ''
        file_handle = File.open(filename, 'r')
		    while line = file_handle.gets
		      result += line.sub(/^\s*$/, '@==@').sub(/\n/, '@@')
		    end
        file_handle.close
		    return result
		  end
		
		  def initialize(filename, debug = false)
		    @debug = debug
		    @filename = filename
		    @single_line = input_conditioner
		    @session = nil
		  end
		
		public
		
		  def context_partitioner
		    didx = single_line.index(/\s+Il\s+nastro\s+contiene:/)
		    cidx = single_line.index(/\s+Il\s+presunto\s+contenitore/)
		    bidx = single_line.index(/--@@\$Id/)
		
		    description = single_line[0..didx-1]
		    content = single_line[didx..cidx-1]
		    box = single_line[cidx..bidx-1]
		
		    return [description, content, box]
		  end
		
		  def compile
		    (d, c, b) = context_partitioner
        tape = Tdp::Tape::Item.new
		
		    tdp = Tdp::Tape::DescriptionParser.new(tape, debug)
        tdp.parse(d)
		
		    tcp = Tdp::Tape::ContentParser.new(tape, debug)
		    tcp.parse(c)

		    tbp = Tdp::Tape::BoxParser.new(tape, debug)
		    tbp.parse(b)

		    return tape
		  end
		
		end
	
	end

end
