#
# $Id: 20090417-repair_rotativa.rb 372 2009-04-18 02:14:55Z nicb $
#

name = 'bootstrap'
u = User.authenticate(name, '__fishrdb_bootstrap__')
raise "User #{name} authentication failed!" unless u && u.valid?

identity_name = "Rotativa. Movimento sinfonico"

def change_score(user, name)
  score_parent = Score.find(:first, :conditions => ["name = ? and tipologia_documento_score = ?",
                         name, "manoscritto"])
	raise ActiveRecord::RecordNotFound.new("Score \"#{name}\" not found!") unless score_parent && score_parent.valid?
	
 	score_parent.children(true).each do
 	  |c|
 	  c.user_update_attribute(user, :name, score_parent.raw_name)
 	  c.save!
 	end
end

change_score(u, identity_name)
