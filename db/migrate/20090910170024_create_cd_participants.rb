#
# $Id: 20090910170024_create_cd_participants.rb 441 2009-09-20 21:37:07Z nicb $
#
class CreateCdParticipants < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
	    create_table :cd_participants, :id => false do |t|
	      t.integer :cd_data_id, :null => false
	      t.integer :name_id, :null => false
        t.integer :position, :null => false
	    end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      drop_table :cd_participants
    end
  end
end
