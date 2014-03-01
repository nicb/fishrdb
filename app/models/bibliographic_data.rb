#
# $Id: bibliographic_data.rb 543 2010-09-08 02:03:17Z nicb $
#

class BibliographicData < ActiveRecord::Base

  belongs_to :bibliographic_record
  set_primary_key :bibliographic_record_id

  validates_presence_of :bibliographic_record_id

  validates_associated :bibliographic_record

  composed_of(:issue_year, :class_name => 'ExtDate::Year',
              :mapping => [ :issue_year_db_record, :to_s ])

  composed_of(:publishing_date, :class_name => 'ExtDate::Base', :mapping =>
             [
               [ :publishing_date_db_record, :to_s ],
               [ :publishing_date_input_parameters, :input_parameters ],
               [ :publishing_date_format, :ed_format ],
             ])
end
