#
# $Id: 20090313-correct_allegato_docs_again.rb 330 2009-03-12 23:38:41Z nicb $
#
# this script corrects some of the scores that appear as "Allegato" while they
# should instead be "Unità Documentaria"
#

u = User.authenticate('bootstrap','__fishrdb_bootstrap__')
docs = Score.find(:all, :conditions => ["description_level_id = ?", DescriptionLevel.allegato.id])

ActiveRecord::Base.transaction do
	docs.each do
	  |s|
	  dl = s.children(true).empty? ? DescriptionLevel.unita_documentaria : DescriptionLevel.sottofascicolo
	  s.user_update_attribute(u, :description_level_id, dl.id)
	  s.save!
    s.reload
    raise "Record unchanged" if s.description_level == DescriptionLevel.allegato
	end
end
