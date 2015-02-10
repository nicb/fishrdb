
module Fishrdb

  module XmlExport

    #
    # <tt>Fishrdb::XmlExport::File</tt> handles the creation
    # of the XML output file
    #
    class File

      attr_reader :path, :file_handle

      def initialize
        @path = create_path
      end

      def save(s, mode = 'a')
        open(mode)
        self.file_handle.puts(s)
        close
      end

			def xml_header
				self.save('<?xml version="1.0" encoding="UTF-8"?>', 'w')
			end

    private

      def open(mode = 'a')
        @file_handle = ::File.open(self.path, mode) unless self.file_handle
        self.file_handle
      end

      def close
        self.file_handle.close
        @file_handle = nil
      end

      BASE_PATH = ::File.expand_path(::File.join(['..'] * 4, 'tmp'), __FILE__)

      def create_path
        tstring = Time.now.strftime("%Y%m%d")
        ::File.join(BASE_PATH, "Fishrdb_#{tstring}.xml")
      end

    end

  end

end
