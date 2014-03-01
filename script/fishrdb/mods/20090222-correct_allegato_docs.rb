#
# $Id: 20090222-correct_allegato_docs.rb 327 2009-03-09 21:34:37Z nicb $
#
# this script corrects some of the scores that appear as "Allegato" while they
# should instead be "Unità Documentaria"
#

u = User.authenticate('bootstrap','__fishrdb_bootstrap__')
docs = Score.find(:all, :conditions => ["description_level_id = ?", DescriptionLevel.allegato.id])

ActiveRecord::Base.transaction do
	docs.each do
	  |s|
	  dl = DescriptionLevel.unita_documentaria
	  s.user_update_attribute(u, :description_level_id, dl.id)
	  s.save!
    s.reload
    raise "Record unchanged" if s.description_level_id == DescriptionLevel.allegato.id
	end
end
