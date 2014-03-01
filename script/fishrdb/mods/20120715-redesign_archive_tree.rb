#
# $Id: 20120715-redesign_archive_tree.rb 619 2012-09-23 15:59:12Z nicb $
#
RAILS_ROOT = File.join(File.dirname(__FILE__), ['..'] * 3)
require File.join(RAILS_ROOT, 'config', 'environment')

#
# This is what this script is supposed to do:
# 
# - further subdivide the fondi like this:
#
#   * Fondo Giacinto Scelsi
#     + Archivio Musicale
#     + Archivio Privato
#   * Fondo Fondazione Isabella Scelsi
#     + Bibliografia
#     + Fondazione Isabella Scelsi
#
# - the description level should be modified accordingly

user = 'bootstrap'
u = User.find_by_login(user)
raise RuntimeError, "Invalid user #{user}: #{u.errors.full_time.join(', ')}" unless u.valid?
ct = ContainerType.find_by_container_type('')
raise RuntimeError, "Invalid container type: #{ct.errors.full_time.join(', ')}" unless ct.valid?

def create_fondo(fname, u, ct, corda_alpha)
	fondo = Folder.create(:name => fname,
											:parent => Document.root,
	  									:description_level_id => DescriptionLevel.fondo.id,
		  								:creator => u,
			  							:last_modifier => u,
				  						:position => 0,
					  					:container_type => ct,
											:corda_alpha => corda_alpha)

	raise RuntimeError, "Could not create folder \"#{fname}\": #{fondo.errors.full_time.join(', ')}" unless fondo.valid?
	fondo
end

def reparent_section(parent, s_name, idx, u)
	s = Document.find_by_name(s_name)
	raise ActiveRecord::RecordNotFound, "Section #{s_name} not found" unless s && s.valid?
	s.update_attributes(:parent => parent, :last_modifier => u, :type => 'Folder',
											:description_level_id => DescriptionLevel.sezione.id,
											:position => idx)
	raise RuntimeError, "Could not update section #{s_name}: #{s.errors.full_messages.join(', ')}" unless s.valid?
	s
end

fgs_assignements  = [ 'Fondo privato', 'Fondo musicale' ]
ffis_assignements = [ 'Bibliografia', 'Fondazione Isabella Scelsi' ] 

ActiveRecord::Base.transaction do

	fgs  = create_fondo('Fondo Giacinto Scelsi', u, ct, 'GS')
	ffis = create_fondo('Fondo Fondazione Isabella Scelsi', u, ct, 'FIS')

	fgs_assignements.each_with_index { |name, idx| reparent_section(fgs, name, idx, u) }
	ffis_assignements.each_with_index { |name, idx| reparent_section(ffis, name, idx, u) }

	fgs.renumber_children_cordas
	ffis.renumber_children_cordas

end
