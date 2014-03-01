#
# $Id: 20090209-reparent_senza_titolo.rb 327 2009-03-09 21:34:37Z nicb $
#
# This script removes the "Cartella Virtuale ..." description from GS scores
#
u = User.authenticate('staff', 'testtest')
pGS = Folder.find_by_name('Partiture Giacinto Scelsi')
pGSst = Score.find_by_name('Partiture Giacinto Scelsi senza titolo')

fds = Folder.find(:all, :conditions => ["parent_id = ? and name like ?",
                  pGS.id, '%senza titolo%'])

fds.reverse.each do
  |f|
  f.reparent_me(pGSst)
  f.update_attribute(:last_modifier, u)
  f.save
end

fds = Folder.find(:all, :conditions => ["parent_id = ?", pGSst.id])
raise "Reparenting did not succeed!" if fds.blank?

fds.each do
  |f|
  raise "Reparenting for Folder #{f.full_name} was not right!" if f.name !~ /senza titolo/i
end

exit(0)
