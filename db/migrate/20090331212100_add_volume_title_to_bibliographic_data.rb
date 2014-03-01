#
# $Id: 20090331212100_add_volume_title_to_bibliographic_data.rb 347 2009-03-31 21:36:28Z nicb $
#
class AddVolumeTitleToBibliographicData < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :bibliographic_data, :volume_title, :string
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :bibliographic_data, :volume_title
    end
  end
end
