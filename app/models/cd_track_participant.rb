#
# $Id: cd_track_participant.rb 462 2009-10-12 01:07:40Z nicb $
#
class CdTrackParticipant < ActiveRecord::Base
  belongs_to :cd_track
  validates_presence_of :cd_track_id
  set_primary_key :cd_track_id
  acts_as_list
end

class CdTrackParticipantPerson < CdTrackParticipant
  belongs_to :name
  validates_presence_of :name_id
end

class CdTrackAuthor < CdTrackParticipantPerson
end

class CdTrackPerformer < CdTrackParticipant
  belongs_to :performer
  validates_presence_of :performer_id
end

class CdTrackEnsemble < CdTrackParticipant
  belongs_to :ensemble
  validates_presence_of :ensemble_id
end
