#
# $Id: 20110222-other_composers_tree.rb 610 2011-02-22 02:21:00Z nicb $
#

uname = 'bootstrap'
u = User.authenticate(uname, '__fishrdb_bootstrap__')
f = Folder.find_by_name('Partiture altri autori')
ct = ContainerType.find_by_container_type('scatola')

def create_alpha_sequence
  (?A..?Z).map { |cn| cn.chr }
end

folder_ids = f.children(true).map { |c| c.id unless c.name.size == 1 }.compact

create_alpha_sequence.each do
  |af|
  conditions =  { :parent_id => f.id, :name => af, :container_type_id => ct.id, :description_level_id => DescriptionLevel.sottoserie.id, :creator_id => u.id, :last_modifier_id => u.id }
  aff = Folder.first(:conditions => conditions) || Folder.create(conditions)
  raise "Folder #{af} not found or created" unless aff
  raise "Invalid Folder #{af}: #{aff.errors.full_messages.join(', ')}" unless aff.valid?
end

folder_ids.each do
  |id|
  c = Folder.find(id)
  raise "Folder #{c.name} not found" unless c
  raise "Invalid Folder #{c.name}: #{c.errors.full_messages.join(', ')}" unless c.valid?
  first_letter = c.name[0]
  new_parent = Folder.find_by_name_and_parent_id(first_letter.chr, f.id)
  raise "Folder #{first_letter.chr} not found" unless new_parent
  raise "Invalid Folder #{new_parent.name}: #{new_parent.errors.full_messages.join(', ')}" unless new_parent.valid?
  c.reparent_me(new_parent)
  c.update_attributes!(:description_level_id => DescriptionLevel.sottosottoserie.id, :last_modifier => u)
  new_parent.reorder_children(:alpha)
  new_parent.reorder_children # puts them back to logic order establishing positions
  new_parent.renumber_children_cordas
  new_parent.children(true).each { |npc| npc.renumber_children_cordas }
end

f.renumber_children_cordas
