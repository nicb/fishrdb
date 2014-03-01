#
# $Id: 20090207-recondition_GS_score_tree.rb 327 2009-03-09 21:34:37Z nicb $
#

pGS = Folder.find_by_name("Partiture Giacinto Scelsi")
dlsGS = DescriptionLevel.fascicolo
ctGS = ContainerType.find_by_container_type('')
u = User.authenticate('bootstrap', '__fishrdb_bootstrap__')

pGS.children.reload

pGSnames = pGS.children.map { |s| s.name }.uniq

pos = 1
pGSnames.each do
  |n|
  container = Folder.create(:name => n, :description_level_id => dlsGS.id,
                            :parent => pGS, :position => pos,
                            :creator => u, :last_modifier => u,
                            :description => "Contenitore virtuale della partitura \"#{n}\"")
  raise StandardError unless container.valid?
  pos += 1
  scores = Score.find(:all, :conditions => ["name = ? and parent_id = ?", n, pGS.id ],
                     :order => 'position')
  subpos = 1
  scores.each do
    |s|
    s.reparent_me(container, subpos)
    s.save
    subpos += 1
  end
  pGS.children.reload
end

pGS.reorder_children(:alpha)
pGS.children.reload

def reorganize_dl(doc)
  dl = doc.no_children? ? DescriptionLevel.unita_documentaria :
      DescriptionLevel.find(doc.parent.description_level.id + 1)
  raise ActiveRecord::RecordNotFound, "DescriptionLevel for level #{doc.parent.description_level.id + 1} not found" unless dl
  doc.update_attributes!(:description_level_id => dl.id)
end

def reorganize_form(doc)
  fd = doc.is_a_part? ? 'parte staccata' : 'partitura'
  doc.update_attributes!(:forma_documento_score => fd)
end

def reorganize_dls(doc)
  reorganize_dl(doc)
  reorganize_form(doc)
  doc.children.reload
  doc.children.each do
    |c|
    reorganize_dls(c)
  end
end

ActiveRecord::Base.transaction do
	pGS.children.each do
	  |v|
	  v.children.each do
	    |vc|
	    reorganize_dls(vc)
	  end
	end
end
