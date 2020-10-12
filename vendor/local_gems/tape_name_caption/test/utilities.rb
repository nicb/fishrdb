#
# $Id: utilities.rb 554 2010-09-12 16:48:50Z nicb $
#

module TapeNameCaption

  module Test

			module Utilities
			
			  TAPE_FILENAME_FIXTURE = File.join(File.dirname(__FILE__), 'fixtures', 'tape_lofi.list.txt')
			
			  def read_tape_filenames
			    result = []
			    File.open(TAPE_FILENAME_FIXTURE) do
			      |fh|
			      while (line = fh.gets)
			        result << line.chomp unless line =~ /^\s*#/
			      end
			    end
			    return result
			  end
			
			end

  end

end
