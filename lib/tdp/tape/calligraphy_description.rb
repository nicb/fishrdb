#
# $Id: calligraphy_description.rb 387 2009-04-25 23:25:22Z nicb $
#

module Tdp

  module Tape

    class CalligraphyDescription

      attr_accessor :pen, :author, :additional_info

    private

      class << self

        def condition_author(string)
          return string.sub(/\)\s*\Z/, '')
        end

      end

      def initialize(pen, author, a_i = '')
        @pen = pen
        @author = self.class.condition_author(author)
        @additional_info = a_i
      end

     public

      def author=(string)
        @author = self.class.condition_author(author)
      end

    end

  end

end
