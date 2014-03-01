#
# $Id: 20100507-update_paa.rb 497 2010-05-07 22:51:46Z nicb $
#

uname = 'bootstrap'
u = User.authenticate(uname, '__fishrdb_bootstrap__')
f = Folder.find_by_name('Partiture altri autori')
ct = ContainerType.find_by_container_type('scatola')

def define_name(s)
  if s =~ /^[Dd]e / || s =~ /^[Mm]ac /
    (de, last, first) = s.split(/\s+/, 3)
    last = de + ' ' + last
  elsif s =~ /^D'Ayala.*G/
    last = "D'Ayala-Valva"
    first = "Giuseppe"
  elsif s =~ /^Senza autore/
    last = s
    first = nil
  else
    (last, first) = s.split(/\s+/, 2)
  end
  last.strip.chomp!(',') if last
  first.strip.chomp(',') if first
  result = [last, first].compact.join(', ')
  result.gsub!(/,,/, ',')
  return result
end



f.children(true).each do
  |s|
  name = define_name(s.autore_score)
  sf = Folder.find_or_create_by_name(:name => name, :creator => u,
                                     :parent => f, :last_modifier => u,
                                     :description_level_id => DescriptionLevel.sottoserie.id,
                                     :container_type => ct)
  s.update_attributes!(:parent => sf)
end
