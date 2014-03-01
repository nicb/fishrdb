#
# $Id: alphabetizer.rb 612 2011-06-13 02:09:14Z nicb $
#

class Alphabetizer

  attr_reader :creator, :container_type, :super_parent, :parent_folders

  def initialize(uname, ct_name, sp_name)
    @creator = User.authenticate(uname, '__fishrdb_bootstrap__')
    raise(ActiveRecord::RecordNotFound, "Could not find user \"#{uname}\"") unless @creator && @creator.valid?
    @container_type = ContainerType.find_by_container_type(ct_name)
    raise(ActiveRecord::RecordNotFound, "Could not find container type \"#{ct_name}\"") unless @container_type && @container_type.valid?
    @super_parent = Document.find_by_name(sp_name)
    raise(ActiveRecord::RecordNotFound, "Could not find document \"#{sp_name}\"") unless @super_parent && @super_parent.valid?
    @parent_folders = {}
  end

  def alphabetize
    folder_ids = self.super_parent.children(true).map { |c| c.id unless c.name.size == 1 }.compact
    folder_ids.each do
      |id|
      c = Document.find(id)
      raise(ActiveRecord::RecordNotFound, "Document #{c.name} not found") unless c
      raise(ActiveRecord::RecordNotFound, "Invalid Document #{c.name}: #{c.errors.full_messages.join(', ')}") unless c.valid?
      np = find_or_create_parent(c)
      c.reparent_me(np)
      np.reorder_children(:alpha)
      np.renumber_children_cordas
    end
    self.super_parent.renumber_children_cordas
  end

private

  def find_or_create_parent(doc)
    first_letter = first_alpha_char(doc)
    new_parent = self.parent_folders[first_letter]
    unless new_parent
      args =  { :parent_id => self.super_parent.id, :name => first_letter, :container_type_id => self.container_type.id, :description_level_id => DescriptionLevel.sottoserie.id, :creator_id => self.creator.id, :last_modifier_id => self.creator.id }
      new_parent = Folder.create(args)
      raise(ActiveRecord::RecordNotFound, "Could not create folder \"#{first_letter}\"") unless new_parent && new_parent.valid?
      self.parent_folders.update(first_letter => new_parent)
    end
    new_parent
  end

  def first_alpha_char(doc)
    title = doc.name
    res = 0
    0.upto(title.size-1) do
      |n|
      res = doc.name[n].chr.upcase
      break if res =~ /[A-Z]/
    end
    res
  end

end
