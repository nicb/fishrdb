#
# $Id: mapper.rb 546 2010-09-08 22:44:40Z nicb $
#
require 'singleton'

module Tdp

  module Tape

    class TapeNotFound < StandardError
    end

    class Importer

      SESSION_FILES_PATH = File.expand_path(File.join(['..' * 4, 'public', 'private', 'session-notes', 'version-1') 

      include Singleton

      class << self

        def import(from = 1, to = nil)
          instance.create_tape_records(from, to)
        end

      end

      def import(from = 1, to = nil)

      end

    private

    end

  end

end

