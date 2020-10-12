#
# $Id: collective_name.rb 517 2010-07-10 20:55:56Z nicb $
#

class CollectiveName < AuthorityRecord
	has_many	:collective_name_variants, :foreign_key => 'authority_record_id', :order => "name", :dependent => :destroy
  belongs_to :cn_equivalent
  attr_readonly         :children_count
	public_class_method		:new, :create
	validates_uniqueness_of	:name, :scope => [:date_start, :date_end], :message => "&egrave; gi&agrave; stato inserito"


public
  DATE_START = 1800
  DATE_END   = 2050
  NEW_EQUIVALENCE_MESSAGE = 'Crea nuova forma equivalente'

  def add_to_collective_name_equivalent(cneq_name, user)
    cneq = CnEquivalent.find_by_name(cneq_name)
    unless cneq
      cneq = CnEquivalent.create(:name => cneq_name, :creator => user, :last_modifier => user) 
    end
    cneq.add_collective_name(self, user)
  end

  def remove_from_collective_name_equivalent(user)
    cneq = self.collective_name_equivalent
    cneq.remove_collective_name(self, user) if cneq
  end

  def self.equivalent_select
    result = CnEquivalent.find(:all, :order => 'name').map { |cn| cn.name }
    result.unshift('')
    return result
  end

  def selected_equivalent
    result = CollectiveName.equivalent_select[0]
    if cn_equivalent
      result = cn_equivalent.name
    end
    return result
  end

  def full_display
    add_on = ''
    add_on = ' (' if date_start or date_end
    if date_start
      add_on = add_on + date_start.year.to_s
    end
    if date_end
      add_on += '-' if date_start
      add_on += date_end.year.to_s
    end
    add_on += ')' unless add_on.blank?
    return name + add_on
  end

end

class CollectiveNameVariant < CollectiveName
	belongs_to	:accepted_form, :class_name => 'CollectiveName', :foreign_key => 'authority_record_id', :counter_cache => :children_count
	validates_presence_of	:authority_record_id

  include AuthorityRecordParts::VariantMethods

end

CollectiveName.class_eval do
  include AuthorityRecordParts::DisplayMethods::CollectiveNameParts
end
