#
# $Id: shouter.rb 572 2010-12-12 18:37:32Z nicb $
#
require 'benchmark'

module BundleGenerator

  class Shouter

    attr_accessor :shout, :output, :indent

    def initialize(o = STDOUT, v = true, i = 0)
      @output = o
      @shout = v
      @indent = i
    end

    def say(msg, lind = nil)
      local_indent = lind ? lind : self.indent 
      if self.shout
        self.output.write((' ' * local_indent) + msg)
        self.output.flush
      end
    end

    def say_with_time(after_msg, before_msg = '', before_indent = nil, &block)
      say(before_msg, before_indent) unless before_msg.blank?
      tms = Benchmark.measure { yield }
      say("%s %s\n" % [after_msg, tms.format('%r secs')])
    end

  end

end
