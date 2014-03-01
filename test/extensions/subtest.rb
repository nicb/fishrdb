#
# $Id: subtest.rb 509 2010-06-13 06:14:04Z nicb $
#

module Test
  module Extensions
    
    DEFAULT_SUBTEST_CHARACTER = '+' unless defined?(DEFAULT_SUBTEST_CHARACTER)

    def subtest_finished(sc = DEFAULT_SUBTEST_CHARACTER)
      $stdout.write(sc)
      $stdout.flush
    end
  end

end
