#
# $Id: cd_data.rb 462 2009-10-12 01:07:40Z nicb $
#
require 'cd_participant'

class CdData < ActiveRecord::Base

  belongs_to :cd_record
  set_primary_key :cd_record_id

  validates_presence_of :cd_record_id

  composed_of(:publishing_year, :class_name => 'ExtDate::Year',
              :mapping => [ [:publishing_year_db_record, :to_s] ])


  has_many :cd_booklet_authors, :dependent => :destroy
  has_many :booklet_authors, :through => :cd_booklet_authors,\
           :source => :name, :order => 'position'

  def inspect
    sel_attrs = [:record_label, :catalog_number, :publishing_year]
    result = two_part_inspect(sel_attrs, nil) do
	    ba_result = []
	    booklet_authors.each do
	      |ba|
	      ba_result << ba.inspect
	    end
	    "booklet_authors: [" << ba_result.join(', ') << "]"
    end
    return result
  end

  def clear_all_associations
    return booklet_authors.clear # removes all join records before re-adding them again
  end

end
