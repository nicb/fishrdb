module Fishrdb

  module Stats

    module Output

      private

        def print_output(name, cnt)
          printf("%-40s %5d\n", name.gsub(/à/, 'a`') + ':', cnt)
        end

        def bar
          "==============================================="
        end

        def print_output_header(title)
          puts("#{bar}\n#{title}:")
        end

        def print_output_trailer
          puts(bar)
        end

    end

  end

end
