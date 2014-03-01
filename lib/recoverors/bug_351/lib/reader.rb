#
# $Id$
#

require 'archive'

module Recoverors

  module Bug351

    class Extractor

      attr_reader :tarfile_path

      def initialize(tf)
        @tarfile_path = tf
      end

      def extract(file)
      end

    end

  end

end
