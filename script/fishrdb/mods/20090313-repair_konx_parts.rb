#
# $Id: 20090313-repair_konx_parts.rb 329 2009-03-12 23:27:58Z nicb $
#

name = 'bootstrap'
u = User.authenticate(name, '__fishrdb_bootstrap__')
raise "User #{name} authentication failed!" unless u && u.valid?


def change_konx(user, name)
  konx_parent = Score.find_by_name('Konx-Om-Pax')
	konx = Score.first(:conditions => ["name = ? and parent_id = ?",
	                  name, konx_parent.id])
	raise ActiveRecord::RecordNotFound unless konx && konx.valid?
	
	konx.children(true).each do
	  |c|
	  c.user_update_attribute(user, :name, konx.name)
	  c.save!
	end
end

change_konx(u, 'I-II-III parte: partitura, copia eliografica')
change_konx(u, 'III parte: partitura, copia eliografica')
