#
# $Id: 20090904234648_create_cd_track_participants.rb 462 2009-10-12 01:07:40Z nicb $
#
class CreateCdTrackParticipants < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      create_table :cd_track_participants do |t|
        t.string    :type, :limit => 256
        t.integer   :cd_track_id, :null => false
        t.integer   :name_id
        t.string    :name_type, :limit => 256
        t.integer   :position
        #
        # CdTrackPerformer
        #
        t.integer   :performer_id
        #
        # CdTrackEnsemble and CdTrackEnsembleConductor
        #
        t.integer   :ensemble_id
      end
      add_index :cd_track_participants, :cd_track_id
      add_index :cd_track_participants, :name_id
      add_index :cd_track_participants, :performer_id
      add_index :cd_track_participants, :ensemble_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :cd_track_participants
    end
  end
end
