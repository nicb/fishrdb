#
# $Id: score_title.rb 517 2010-07-10 20:55:56Z nicb $
#

class ScoreTitle < AuthorityRecord
	has_many	:score_title_variants, :foreign_key => 'authority_record_id', :order => "name", :dependent => :destroy

  belongs_to :author,      :class_name => 'PersonName'
  belongs_to :transcriber, :class_name => 'PersonName'
  belongs_to :lyricist,    :class_name => 'PersonName'

  attr_readonly         :children_count
	public_class_method		:new, :create
  validates_uniqueness_of	:name, :scope => [:organico, :author_id, :transcriber_id, :lyricist_id],
                          :message => "è già stato inserito"
end

class ScoreTitleVariant < ScoreTitle
	belongs_to	:accepted_form, :class_name => 'ScoreTitle', :foreign_key => 'authority_record_id', :counter_cache => :children_count
	validates_presence_of	:authority_record_id
  validates_uniqueness_of	:name, :scope => :authority_record_id, :message => "è già stato inserito"

  include AuthorityRecordParts::VariantMethods

end

ScoreTitle.class_eval do
  include AuthorityRecordParts::DisplayMethods::ScoreTitleParts
end
