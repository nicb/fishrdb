#!/usr/bin/env ruby
#
# Creates several CSV files for each authority file record
# along with its variants
#

require 'csv'
require File.expand_path(File.join(['..'] * 3, 'config', 'environment'), __FILE__)

OUTPUT_PATH = File.expand_path(File.join(['..'] * 3, 'tmp', 'fishrdb_objects.csv'), __FILE__)

MODELS = [
  Document,
	AuthorityRecord,
	Name,
  BibliographicData,
  TapeData,
  CdData,
  CdParticipant,
  CdTrack,
  CdTrackParticipant,
	Performer,
	Instrument,
	TapeBoxMarkerCollection,
	TapeBoxMark,
	User,
	ContainerType,
]

CSV.open(OUTPUT_PATH, 'wb') do
  |csv|
  MODELS.each do
    |m|
    attrs = m.columns.map { |c| [ nil, c.name, c.type, c.sql_type, c.limit ] }
    csv << [ m.table_name ]
		m.columns.each do
			|a|
      csv << [ nil, a.name.to_s, a.type.to_s, a.sql_type, a.limit.to_s.blank? ? nil : a.limit.to_s ]
		end
    csv << [ nil ]
    csv << [ "============================================" ]
    csv << [ nil ]
  end
end
