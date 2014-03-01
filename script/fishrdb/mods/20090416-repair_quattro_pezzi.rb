#
# $Id: 20090313-repair_qp_parts.rb 329 2009-03-12 23:27:58Z nicb $
#

name = 'bootstrap'
u = User.authenticate(name, '__fishrdb_bootstrap__')
raise "User #{name} authentication failed!" unless u && u.valid?

identity_name = "Quattro pezzi per orchestra (ciascuno su una nota)"

def change_qp(user, name)
  qp_parent = Score.find(:first, :conditions => ["name = ? and tipologia_documento_score = ?",
                         name, "copia eliografica"])
	raise ActiveRecord::RecordNotFound unless qp_parent && qp_parent.valid?
	
 	qp_parent.children(true).each do
 	  |c|
 	  c.user_update_attribute(user, :name, qp_parent.raw_name)
 	  c.save!
 	end
end

change_qp(u, identity_name)
