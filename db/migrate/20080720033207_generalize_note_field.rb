#
# $Id: 20080720033207_generalize_note_field.rb 246 2008-07-20 04:01:35Z nicb $
#
class GeneralizeNoteField < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      rename_column 'documents', 'note_score', 'note'
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      rename_column 'documents', 'note', 'note_score'
    end
  end
end
