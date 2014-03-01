#
# $Id: csv_reader.rb 444 2009-09-20 23:29:04Z nicb $
#

require 'csv'

module CdImporter

	class CsvReader
	  attr_reader :datafile, :data
	
	  def initialize(df)
	    @datafile = df
	    @data = []
	    reader = CSV.open(@datafile, 'r')
	    reader.map { |l| @data << l }
	  end
	
	protected
	
	  class <<self

      def album_columns
        return [:name, nil, :record_label, :catalog_number, :publishing_year, :booklet_author, :notes]
      end

      def track_columns
        return [nil, :author, :composition_title, :interpreter, :dur, :notes]
      end

	  end
	
	end

end
