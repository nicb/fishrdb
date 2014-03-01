#
# $Id: 20090207-parti_come_sottofascicoli.rb 327 2009-03-09 21:34:37Z nicb $
#
# This will transform all score parts in 'sottofascicolo'
#

root = Folder.find_by_name('Partiture Giacinto Scelsi')

root.children.each do
  |d|
  puts("Partitura: #{d.name}")

  if d.children.reload.size > 0
    d.children.each do
      |c|
      puts("\tDoc: #{c.name} figlio di #{d.name[0..10]}... => sottofascicolo")
      c.update_attributes!(:description_level_id => DescriptionLevel.sottofascicolo.id)
    end
  end
end
