#!/usr/bin/env ruby
#
# Creates several CSV files for each authority file record
# along with its variants
#

require 'csv'
require File.expand_path(File.join(['..'] * 3, 'config', 'environment'), __FILE__)

OUTPUT_PATH = File.expand_path(File.join(['..'] * 3, 'tmp'), __FILE__)

FILES = {
  PersonName => 'nomi',
	ScoreTitle => 'titoli',
	SiteName => 'luoghi',
	CollectiveName => 'enti',
}

FILES.each do
	|klass, filename|

	outfile = File.join(OUTPUT_PATH, filename + '.csv')

	CSV.open(outfile, 'wb') do
		|csv|
		klass.all(:order => 'name, first_name').each do
			|ar|
			row = [ ar.id, [ar.name, ar.first_name].compact.join(' ') ]
			row.concat(ar.variants.map { |v| [v.name, v.first_name].compact.join(' ') })
			csv << row
		end
	end
end
