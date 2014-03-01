#
# $Id: site_name.rb 517 2010-07-10 20:55:56Z nicb $
#

class SiteName < AuthorityRecord
	has_many	:site_name_variants, :foreign_key => 'authority_record_id', :order => "name", :dependent => :destroy
  attr_readonly         :children_count
	public_class_method		:new, :create
	validates_uniqueness_of	:name, :message => "è già stato inserito"

end

class SiteNameVariant < SiteName
	belongs_to	:accepted_form, :class_name => 'SiteName', :foreign_key => 'authority_record_id', :counter_cache => :children_count
	validates_presence_of	:authority_record_id
	validates_uniqueness_of	:name, :scope => :authority_record_id, :message => ": Questa variante è già stata inserita"

  include AuthorityRecordParts::VariantMethods

end

SiteName.class_eval do
  include AuthorityRecordParts::DisplayMethods::SiteNameParts
end
