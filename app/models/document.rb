#
# $Id: document.rb 632 2013-07-12 14:45:53Z nicb $
#

require_dependency File.dirname(__FILE__) + '/../helpers/display/model/display_item'
require_dependency File.dirname(__FILE__) + '/../helpers/display/model/display_helper'
require_dependency 'search_system'

require_dependency 'authority_record'
require_dependency 'ard_reference'
#require_dependency 'search_engine'

class Document < ActiveRecord::Base

	include Display::Model::DisplayHelper
  extend SearchHelper::Model::ClassMethods

  composed_of(:date, :class_name => 'ExtDate::Interval', :mapping =>
              [
                [:data_dal, :to_date_from_s],
                [:data_al, :to_date_to_s],
                [:data_dal_input_parameters, :dfips],
                [:data_al_input_parameters, :dtips],
                [:full_date_format, :intv_format],
                [:data_dal_format, :from_format],
                [:data_al_format, :to_format],
              ])

	acts_as_tree	:order => "position", :counter_cache => :children_count
	acts_as_list	:scope => :parent, :order => "position"

	belongs_to	:creator, :class_name => "User", :foreign_key => :creator_id
	belongs_to	:last_modifier, :class_name => "User", :foreign_key => :last_modifier_id
# belongs_to	:description_level
  belongs_to  :container_type
  belongs_to  :fisold_reference_db, :counter_cache => true
  #
  # the following are all children of AuthorityRecord
  #
  has_many    :person_names, :through => :person_name_ard_references
  has_many    :site_names, :through => :site_name_ard_references
  has_many    :collective_names, :through => :collective_name_ard_references
  has_many    :score_titles, :through => :score_title_ard_references

	has_many    :person_name_ard_references, :dependent => :destroy
	has_many    :site_name_ard_references, :dependent => :destroy
	has_many    :collective_name_ard_references, :dependent => :destroy
	has_many    :score_title_ard_references, :dependent => :destroy
  #
  # associations with sidebar_tree_items
  #
  has_many     :sidebar_tree_items, :dependent => :destroy
  #
  # associations with clipboard_items
  #
  has_many     :clipboard_items, :dependent => :destroy

	validates_presence_of 	:name, :description_level_id, :creator, :last_modifier, :container_type_id
  validates_numericality_of :description_level_id, :container_type_id
  #
  validate :parent_cannot_be_self, :on => :update

	make_searchable  [ :edizione_score, :container_number, :name, :titoli_series, :luoghi_series,
					   :enti_series, :consistenza, :autore_score, :autore_versi_score,
					   :trascrittore_score, :data_al, :data_topica, :titolo_uniforme_score, :note,
					   :anno_composizione_score, :organico_score, :nota_data, :luogo_edizione_score,
					   :description, :nomi_series, :corda, :misure_score, :chiavi_accesso_series,
					   :tipologia_documento_score, :anno_edizione_score, :data_dal,
					   :creator_id, :last_modifier_id ]

	WillPaginate::ViewHelpers.pagination_options[:prev_label] = '&laquo; Prec.'
	WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Seg. &raquo;'
	WillPaginate::ViewHelpers.pagination_options[:inner_window] = 2

end

DOC_PATH = 'document/' unless defined?(DOC_PATH)
require_dependency DOC_PATH + 'crud'
require_dependency DOC_PATH + 'authority_record_collection'
require_dependency DOC_PATH + 'authority_record_management'
require_dependency DOC_PATH + 'authority_record_display'
require_dependency DOC_PATH + 'paginate'
require_dependency DOC_PATH + 'condition_input'
require_dependency DOC_PATH + 'condition_output'
require_dependency DOC_PATH + 'order'
require_dependency DOC_PATH + 'descendant'
require_dependency DOC_PATH + 'parenting'
require_dependency DOC_PATH + 'display_ar'
require_dependency DOC_PATH + 'root'
require_dependency DOC_PATH + 'date_onchange_strings'
#require_dependency DOC_PATH + 'children'
require_dependency DOC_PATH + 'corda'
require_dependency DOC_PATH + 'signature'
require_dependency DOC_PATH + 'full_name'
require_dependency DOC_PATH + 'sidebar_display'
require_dependency DOC_PATH + 'description_level_intf'
require_dependency DOC_PATH + 'public_access'
require_dependency DOC_PATH + 'public_visibility'
require_dependency DOC_PATH + 'proxy'
require_dependency DOC_PATH + 'forms'
require_dependency DOC_PATH + 'sidebar_tree_item'
require_dependency DOC_PATH + 'public_children'
require_dependency DOC_PATH + 'subclass'
require_dependency DOC_PATH + 'dashboard'
require_dependency DOC_PATH + 'validations'
require_dependency DOC_PATH + 'breadcrumbs'

Document.class_eval do
	include DocumentParts::Crud
	include DocumentParts::AuthorityRecordCollection
	include DocumentParts::AuthorityRecordManagement
	include DocumentParts::AuthorityRecordDisplay
	include DocumentParts::Paginate
	include DocumentParts::ConditionInput
	include DocumentParts::ConditionOutput
	include DocumentParts::Order
	include DocumentParts::Descendant
	include DocumentParts::Parenting
	include DocumentParts::DisplayAr
	include DocumentParts::Root
	include DocumentParts::DateOnChangeStrings
	include DocumentParts::Corda
	include DocumentParts::Signature
	include DocumentParts::FullName
	include DocumentParts::SidebarDisplay
  include DocumentParts::DescriptionLevelIntf
  include DocumentParts::PublicAccess
  include DocumentParts::PublicVisibility
  include DocumentParts::Proxy
  include DocumentParts::Forms
  include DocumentParts::SidebarTreeItem
  include DocumentParts::PublicChildren
  include DocumentParts::Subclass
  include DocumentParts::Dashboard
  include DocumentParts::Validations
	include DocumentParts::Breadcrumbs
end

require_dependency DOC_PATH + 'two_part_document'
require_dependency DOC_PATH + 'folder'
require_dependency DOC_PATH + 'series'
require_dependency DOC_PATH + 'score'
require_dependency DOC_PATH + 'bibliographic_record'
require_dependency DOC_PATH + 'tape_record'
require_dependency DOC_PATH + 'cd_track_record'
require_dependency DOC_PATH + 'cd_record'
require_dependency DOC_PATH + 'printed_score'

require_dependency DOC_PATH + 'children'

Document.class_eval do
	include DocumentParts::Children
end

class Document < ActiveRecord::Base
  create_sorters
	
  allow_search_in [ :signature, :full_corda, :full_name, :description, :note, :display_container ],\
                  { :exclude_method => :public_visibility?, :exclude_classes => [ Document, Folder ] }

end
