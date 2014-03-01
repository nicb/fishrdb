#
# $Id: 012_larger_organico_field.rb 174 2008-02-22 22:00:29Z nicb $
#

require 'connection_lib'
require 'display/model/display_item'

def open_dbs
  Fisold.open_db('fisold')
end

def close_dbs
  Fisold.close_db
end

def reload_organico_score
  classes = { 'Partiture_Scelsi' => FisoldGS, 'Partiture_altri_autori' => FisoldAA }
  open_dbs
  scores = Score.find(:all, :conditions => ["fisold_reference_score is not null"])

  scores.each do
    |s|
    fisold_table = s.fisold_reference_db.name
    fodclass = classes[fisold_table]
    fod = fodclass.find(:first, :conditions => ["contatore = ?", s.fisold_reference_score])
    raise ActiveRecord::RecordNotFound, "fisold record for \"#{s.name}\" not found!" unless fod
    s.update_attribute('organico_score', fod.organico)
  end

  close_dbs
end

class LargerOrganicoField < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      change_column :documents, :organico_score, :text
      reload_organico_score
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      change_column :documents, :organico_score, :string, :limit => 512
    end
  end
end
