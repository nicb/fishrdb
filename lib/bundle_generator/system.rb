#
# $Id: system.rb 584 2010-12-19 22:12:55Z nicb $
#
module BundleGenerator

  class System < Base

    attr_reader :output_format
    attr_accessor :output_filename, :tainted

    DEFAULT_OUTPUT_FORMAT = 'targz'

    def initialize(config)
      super(nil)
      @output_format = DEFAULT_OUTPUT_FORMAT
      configure_system(config)
    end

    def tainted?
      self.tainted
    end

    def taint
      self.output_filename += '-INCOMPLETE' unless tainted?
      self.tainted = true
    end

  private

    def configure_system(config)
      raise(OutputFilenameMissing) unless config.has_key?('output_filename')
      @output_filename = config['output_filename']
      @output_format = config['format'] if config.has_key?('format')
    end

  end

end
