#
# $Id: driver.rb 582 2010-12-19 00:31:56Z nicb $
#
require 'yaml'

module BundleGenerator

  class Driver

    attr_accessor :filename, :config, :bundle

    class << self

      def interactive(verbose = true)
        filename = prompt("Configuration file")
        non_interactive(filename, verbose)
      end

      def non_interactive(filename, verbose = true)
        d = Driver.new
        d.shut_up unless verbose
        d.filename = filename
        d.run
      end

      def shouter
        @@shouter ||= Shouter.new
        @@shouter
      end

    private

      def prompt(text, options = {})
        default = options[:default] || ''
        while true
          print "#{text} [#{default}]: "
          STDOUT.flush
          value = STDIN.gets.chomp!
          value = default if value.blank?
          break unless value.blank?
        end
        value
      end

    end

    def run
      result = nil
      self.class.shouter.say_with_time('done!', "Generating") do
        self.config = FileParser.new(self.filename)
        outfile = self.config.data['system']['output_filename']
        self.class.shouter.say(" #{outfile} file")
        self.bundle = Bundle.new(self.config.data)
        result = self.bundle.generate
      end
      result
    end

    def shut_up
      self.class.shouter.shout = false
    end

  end

end
