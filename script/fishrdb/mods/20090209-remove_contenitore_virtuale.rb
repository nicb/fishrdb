#
# $Id: 20090209-remove_contenitore_virtuale.rb 327 2009-03-09 21:34:37Z nicb $
#
# This script removes the "Cartella Virtuale ..." description from GS scores
#
u = User.authenticate('staff', 'testtest')
pGS = Folder.find_by_name('Partiture Giacinto Scelsi')

fds = Folder.find(:all, :conditions => ["parent_id = ? and description like ?",
                  pGS.id, 'Contenitore virtuale della partitura %'])

fds.each do
  |f|
  f.user_update_attribute(u, 'description', nil)
end

fds = Folder.find(:all, :conditions => ["parent_id = ? and description like ?",
                  pGS.id, 'Contenitore virtuale della partitura %'])

raise "Removal did not succeed!" unless fds.blank?

exit(0)
