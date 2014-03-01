#
# $Id: 20090904015437_create_cd_tracks.rb 465 2009-10-15 23:15:54Z nicb $
#
class CreateCdTracks < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :cd_tracks, :id => false do |t|
	      t.integer :cd_track_record_id, :null => false
        t.integer :ordinal # for compositions with many indexes/parts
        t.string  :for, :limit => 8192
        t.time    :duration
        #
        # :name in cd_track_record acts as composition_title
        # :position is included in cd_track_record
        # :notes is included in cd_track_record
        #
	    end
      add_index :cd_tracks, :cd_track_record_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :cd_tracks
    end
  end
end
