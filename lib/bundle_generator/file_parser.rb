#
# $Id: file_parser.rb 572 2010-12-12 18:37:32Z nicb $
#
require 'yaml'

module BundleGenerator

  class FileParser < Base

    attr_reader :filename, :data

    def initialize(filename)
      super(nil)
      @filename = filename
      @data = File.open(self.filename) { |fh| YAML.load(fh) }
      raise(SystemConfigurationMissing) unless @data.has_key?('system')
      raise(OutputFilenameMissing) unless @data['system'].has_key?('output_filename')
    end

  end

end
