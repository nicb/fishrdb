#
# $Id: parent_name.rb 490 2010-04-18 00:59:22Z nicb $
#
require 'document/folder'

module TapeDataParts

  module ParentName

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

        def deduced_parent_name(tag)
          number = tag.split('-')[0].sub(/\ANMGS/,'').to_i
          n_start = ((((number-1) / 20).to_i)*20) + 1
          n_end = n_start + 19
          return sprintf("%04d-%04d", n_start, n_end)
        end

        def tape_root
          return ::Folder.find_by_name_and_description_level_id('Nastri', ::DescriptionLevel.serie.id)
        end

    end

  end

end
