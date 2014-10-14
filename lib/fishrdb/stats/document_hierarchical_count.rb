module Fishrdb

  module Stats

    class DocumentHierarchicalCount

      class << self

        include Output

        EXCLUDE_NAME = '__Fondazione_Isabella_Scelsi__'

        def count
          print_output_header('Documenti')
          #
          # get all description levels
          #
          DescriptionLevel.levels.each do
            |dl|
            cnt = Document.count(:conditions => ['description_level_id = ? AND name != ?', dl.id, EXCLUDE_NAME])
            name = cnt > 1 ? dl.level.pluralize : dl.level
            print_output(name, cnt)
          end

          print_output_trailer
        end

      end

    end # class HierarchicalCount

  end # module Stats

end # module Fishrdb
