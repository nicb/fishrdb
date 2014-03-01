#
# $Id: fis_reader.rb 371 2009-04-17 22:26:58Z nicb $
#

pts_cwd = File.dirname(__FILE__)

require pts_cwd + '/csv_reader'
require pts_cwd + '/tape_item'

class FisReader < CsvReader

  attr_reader :column_names, :hash_data, :tape_items

private

  def hasherize_line(l)
    result = {}
    column_names.each_with_index do
      |k, i|
      result[k] = l[i]
    end
    return result
  end

  def create_objects
    return data.map { |d| Tdp::Csv::TapeItem.new(hasherize_line(d)) }
  end


  def initialize(datafile)
    super(datafile)
    @column_names = @data.shift
    @tape_items = create_objects
  end

end
