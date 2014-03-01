#
# $Id: tape_data.rb 502 2010-05-30 20:56:50Z nicb $
#

require_dependency 'file_extensions'

class TapeData < ActiveRecord::Base

  belongs_to :tape_record
  set_primary_key :tape_record_id

  validates_presence_of :tape_record_id

  has_many :tape_box_marker_collections, :dependent => :destroy

end

TD_PATH = 'tape_data/'
require_dependency TD_PATH + 'create'
require_dependency TD_PATH + 'parent_name'
require_dependency TD_PATH + 'attribute_display'
require_dependency TD_PATH + 'image_display'
require_dependency TD_PATH + 'sound'
require_dependency TD_PATH + 'tape_box_marker_collection_display'

TapeData.class_eval do
  include TapeDataParts::Create
  include TapeDataParts::ParentName
  include TapeDataParts::AttributeDisplay
  include TapeDataParts::ImageDisplay
  include TapeDataParts::Sound
  include TapeDataParts::TapeBoxMarkerCollectionDisplay
end
