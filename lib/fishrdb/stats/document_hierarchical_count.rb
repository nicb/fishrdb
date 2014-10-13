require 'debugger'
module Fishrdb

  module Stats

    class DocumentHierarchicalCount

      class << self

        def count
					output_header
					#
					# get all description levels
					#
					DescriptionLevel.levels.each do
						|dl|
						cnt = Document.count(:conditions => ['description_level_id = ?', dl.id])
						output(dl, cnt)
					end
					output_trailer
        end

      private

				def output(dl, cnt)
					name = cnt > 1 ? dl.level.pluralize : dl.level
					printf("%-20s %20d\n", name + ':', cnt)
				end

				def output_header
					puts("==========================================")
				end

				alias_method :output_trailer, :output_header

      end

    end # class HierarchicalCount

  end # module Stats

end # module Fishrdb
