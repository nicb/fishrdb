#
# $Id: 20090123053401_add_bibliografia_and_cds.rb 329 2009-03-12 23:27:58Z nicb $
#
# This adds two top-level records:
# - Bibliografia (under root)
# - CD (under "Archivio Musicale")
#
# the "down" method is empty because we will check if those two records
# already exist in the first place
#
class AddBibliografiaAndCds < ActiveRecord::Migration

  class <<self

  private

    def conditional_create_record(name, parent, pos, dl, u, ct)
      f = Folder.find(:first, :conditions => ["name = ? and description_level_id = ?",
                                              name, dl.id])
      unless f
        f = Folder.create(:name => name, :parent => parent, :position => pos,
                          :creator => u, :last_modifier => u,
                          :container_type => ct,
                          :description_level_id => dl.id)
        raise ActiveRecord::ActiverRecordError "Created record '#{f.name}' is invalid because #{f.errors.full_messages}" unless f && f.valid?
      end
    end
    
  public

    def create_bibliografia(u, ct)
      p = Document.root
      name = 'Bibliografia'
      pos = 3
      dl = DescriptionLevel.sezione
      conditional_create_record(name, p, pos, dl, u, ct)
    end

    def create_cds(u, ct)
      p = Folder.find_by_name('Archivio Musicale')
      name = 'CD'
      pos = 4
      dl = DescriptionLevel.serie
      conditional_create_record(name, p, pos, dl, u, ct)
    end
  end

  def self.up
    ActiveRecord::Base.transaction do
      u = User.authenticate('bootstrap', '__fishrdb_bootstrap__')
      ct = ContainerType.default_container_type
      create_bibliografia(u, ct)
      create_cds(u, ct)
    end
  end

  def self.down
  end
end
