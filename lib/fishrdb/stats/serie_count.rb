module Fishrdb

  module Stats

    class Serie

      class << self

        include Output

        def count
          print_output_header('Documenti per serie')

          ss = Document.all(:conditions => ['description_level_id = ?', DescriptionLevel.serie.id])

          ss.each do
            |s|
            print_output(s.name, s.count_descendants)
          end

          print_output_trailer
        end

      end

    end # class Serie

  end # module Stats

end # module Fishrdb

