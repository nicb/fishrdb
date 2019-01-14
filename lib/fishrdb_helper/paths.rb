#
# $Id: paths.rb 596 2011-01-03 08:50:36Z nicb $
#
require 'tape_data/parent_name'

module FishrdbHelper

  module Paths

    TAPE_DIR = 'Audio Files'
    TAPE_GLOB = '*-128.mp3'
    IMAGE_DIR = 'Images'
    IMAGE_GLOB = '*-768.jpg'
    TEXT_DIR = '.'
    TEXT_GLOB = '*.txt'

    COMMON_PATH = File.join(File.dirname(__FILE__), '..', '..', 'public', 'private')
    LOFI_PATH = File.join(COMMON_PATH, 'lofi')
    HIFI_PATH = File.join(COMMON_PATH, 'hifi', 'FIS_tapes')
    SESSION_PATH = File.join(COMMON_PATH, 'session-notes', 'version-1')

    def tape_path(base)
      return File.join(lofi_base_dir(base), TAPE_DIR)
    end

    def image_path(base)
      return File.join(lofi_base_dir(base), IMAGE_DIR)
    end

    def text_path(base)
      return File.join(session_base_dir(base), TEXT_DIR)
    end

    def note_path(base)
      return File.join(session_base_dir(base), TEXT_DIR)
    end

    def tape_file_lookup(base)
      return common_lookup(tape_path(base), TAPE_GLOB)
    end

    def image_file_lookup(base)
      return common_lookup(image_path(base), IMAGE_GLOB)
    end

    def text_file_lookup(base)
      return common_lookup(text_path(base), TEXT_GLOB)
    end

    def note_file_lookup(base)
      return common_lookup(note_path(base), 'note.txt')
    end

    def lofi_base_dir(base)
      return File.join(LOFI_PATH, parent_name(base), base)
    end

    def hifi_base_dir(base)
      return File.join(HIFI_PATH, parent_name(base), base)
    end

    def session_base_dir(base)
      return Dir.glob(File.join(SESSION_PATH, '*', base))
    end

  private

    def common_lookup(base, glob)
      return Dir.glob(File.join(base, glob))
    end

    include TapeDataParts::ParentName::ClassMethods

    def parent_name(base)
      return deduced_parent_name(base)
    end

  end

end
