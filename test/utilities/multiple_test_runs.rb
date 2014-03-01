#
# $Id: multiple_test_runs.rb 535 2010-08-21 01:42:42Z nicb $
#

module Test

  module Utilities

		module MultipleTestRuns
		
	    def self.included(base)
	      base.extend ClassMethods
	    end

      module ClassMethods

			  def number_of_runs(n)
			    @nruns = n - 1
			  end
			
			  def verbose(bool)
			    @multiple_test_verbose = bool
			  end

      end
		
		  class MultipleAutoRunner
		    attr_reader :args, :number_of_runs
		    attr_accessor :results
		
		    def initialize(nruns, av = ARGV)
		      @number_of_runs = nruns
		      @args = av.dup
		      @results = []
		    end
		
		    def run
		      0.upto(number_of_runs) do
		        next_args = args.dup
		        @results << Test::Unit::AutoRunner.run(false, nil, next_args)
		      end
		      return @results
		    end
		
		  end
		  #
		  # multiple test runs should be performed only on single tests, not on mass
		  # rake testing
		  #
		  unless $0 =~ /rake/
				at_exit do
			    n = @nruns ? @nruns : 0
				  vals = []
		      mar = MultipleAutoRunner.new(n)
		      mar.run
				  puts("Test results for #{n+1} runs of #{self.class.name} test: [" + mar.results.join(', ') + "]") if @multiple_test_verbose
				  exit(mar.results.last)
				end
		  end
		
		end

  end

end
