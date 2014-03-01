#
# $Id: lofi.rb 596 2011-01-03 08:50:36Z nicb $
#

module FishrdbHelper

  module Lofi

    LINEAR_FILE_SUFFIX = '.aif'
    COMPRESS_FILE_SUFFIX = '.mp3'
    BITRATE = '128'

    def lofi_file_prefix(source_file)
      case source_file
      when /#{LINEAR_FILE_SUFFIX}$/
        File.basename(source_file, LINEAR_FILE_SUFFIX) + '-' + BITRATE
      when /#{COMPRESS_FILE_SUFFIX}$/
        File.basename(source_file, COMPRESS_FILE_SUFFIX)
      else
        source_file
      end
    end

    def lofi_file_source_path(source_file)
      source_file.sub(/#{LINEAR_FILE_SUFFIX}/,'') + '-' + BITRATE + COMPRESS_FILE_SUFFIX
    end

    alias :reference_file :lofi_file_source_path

  end

end
