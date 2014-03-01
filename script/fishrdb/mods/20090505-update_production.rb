#
# $Id: 20090505-update_production.rb 405 2009-05-05 11:22:01Z nicb $
#
# - CD + dischi non visibili
# - Partiture scelsi non visibili
# - passata la bibliografia a unita` documentarie
# - documenti personali e patrimoniali consultabilita` no 
# - propagazione della non-accessibilita`
#

['Dischi', 'CD', 'Partiture Giacinto Scelsi senza titolo'].each do
	|name|
	d = Folder.find_by_name(name)
	d.public_visibility = false
	d.save!
end

f = Folder.find_by_name('Bibliografia')
f.children(true).each do
	|c|
	c.description_level_id = DescriptionLevel.unita_documentaria.id
	c.save!
end

dpp = Series.find_by_name('Documenti Personali e Patrimoniali')
dpp.public_access = false
dpp.save!
dpp.children(true).each do
	|c|
	c.public_access = false
	c.save!
	c.children(true).each do
		|cc|
		cc.public_access = false
		cc.save!
	end
end

def set_public_access_to_false(root)
	root.public_access = false
	root.save!

	root.children(true).each do
		|c|
		set_public_access_to_false(c)
	end
end

scores = Folder.find_by_name('Partiture Giacinto Scelsi')

scores.children(true).each do
	|c|
	set_public_access_to_false(c) unless c.public_access
end
exit(0)
