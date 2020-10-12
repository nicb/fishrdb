module Fishrdb

  module Stats

    class AuthorityCount

      class << self

        include Output

        AUTHORITIES =
        [
          { 'PersonName' => 'Nomi di persona' },
          { 'PersonNameVariant' => 'Nomi di persona (forme varianti)' },
          { 'CollectiveName' => 'Nomi di enti' },
          { 'CollectiveNameVariant' => 'Nomi di enti (forme varianti)' },
          { 'SiteName' => 'Nomi di localita`' }, 
          { 'SiteNameVariant' => 'Nomi di localita` (forme varianti)' },
          { 'ScoreTitle' => 'Titoli di partiture' },
          { 'ScoreTitleVariant' => 'Titoli di partiture (forme varianti)' },
        ]

        def count
          print_output_header('Authority Files')

          AUTHORITIES.each do
            |h|
            klass = h.keys.first.constantize
            print_output(h.values.first, klass.count)
          end

          print_output_trailer
        end

      end

    end # class HierarchicalCount

  end # module Stats

end # module Fishrdb
