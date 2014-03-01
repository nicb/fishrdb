#
# $Id: 20080719043730_enhance_score_title_records.rb 245 2008-07-20 03:29:36Z nicb $
#
class EnhanceScoreTitleRecords < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      add_column :authority_records, :author_id, :integer
      add_column :authority_records, :transcriber_id, :integer
      add_column :authority_records, :lyricist_id, :integer
      #
      add_index  :authority_records, :author_id
      add_index  :authority_records, :transcriber_id
      add_index  :authority_records, :lyricist_id
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_index  :authority_records, :author_id
      remove_index  :authority_records, :transcriber_id
      remove_index  :authority_records, :lyricist_id
      #
      remove_column :authority_records, :author_id
      remove_column :authority_records, :transcriber_id
      remove_column :authority_records, :lyricist_id
    end
  end
end
