#
# $Id: 20090408071820_change_bibliographic_volume_to_string.rb 358 2009-04-08 08:16:15Z nicb $
#
class ChangeBibliographicVolumeToString < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      change_column :bibliographic_data, :volume, :string, :limit => 64
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      change_column :bibliographic_data, :volume, :integer
    end
  end
end
