#
# $Id: cd_participant.rb 441 2009-09-20 21:37:07Z nicb $
#
class CdParticipant < ActiveRecord::Base
  belongs_to :cd_data
  set_primary_key :cd_data_id

  validates_presence_of :cd_data_id
  acts_as_list
end

class CdBookletAuthor < CdParticipant
  belongs_to :name
  validates_presence_of :name_id
end
