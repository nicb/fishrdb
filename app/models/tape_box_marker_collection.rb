#
# $Id: tape_box_marker_collection.rb 502 2010-05-30 20:56:50Z nicb $
#
class TapeBoxMarkerCollection < ActiveRecord::Base

  belongs_to :tape_data
  has_many   :tape_box_marks, :dependent => :destroy

  validates_presence_of :tape_data_id, :location

end
