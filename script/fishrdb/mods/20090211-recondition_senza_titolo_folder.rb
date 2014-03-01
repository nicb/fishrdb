#
# $Id: 20090211-recondition_senza_titolo_folder.rb 327 2009-03-09 21:34:37Z nicb $
#
# This script reconditions the 'senza titolo' record (which is badly done)
#
u = User.authenticate('staff', 'testtest')
pGSst = Document.find_by_name('Partiture Giacinto Scelsi senza titolo')

pGSst.user_update_attribute(u, :type, 'Folder')
pGSst.user_update_attribute(u, :description_level_id, DescriptionLevel.sottoserie.id)
pGSst.save!

exit(0)
