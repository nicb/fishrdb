#
# $Id: authority_record.rb 616 2012-06-21 11:47:43Z nicb $
#
# Here is how authority records are constructed:
#
# The base class gets subclassed for all categories.
# The tree is as follows:
#
#                           AuthorityRecord
#                                 |
#       +--------------------+----+------------+---------------+
#       |                    |                 |               |
#       v                    v                 v               v
# CollectiveName        PersonName         SiteName       ScoreTitle
#       |                    |                 |               |
#       v                    v                 v               v
#      CNE                  PNE               SNE             STE
#
# In general, an AuthorityRecord has many authority variant form records linked
# to it (see the AuthorityVariant model)
# The CollectiveName has also many TimebasedEquivalent models
#
# uniqueness validation must be performed *PER CLASS* because duplicates may
# exist between classes.
# added_path = File.expand_path(__FILE__).gsub(/\.rb$/, '')
# $:.unshift(added_path) unless $:.include?(added_path)

class AuthorityRecord < ActiveRecord::Base
	has_many    :documents, :through => :ard_references
  has_many    :ard_references, :dependent => :destroy

	belongs_to	:creator, :class_name => 'User'
	belongs_to	:last_modifier, :class_name => 'User'

	validates_presence_of	:name, :if => :allow_name_validation
  validates_presence_of :creator_id
  validates_presence_of :last_modifier_id

	#
	# the parent should not be created by itself
	#
	private_class_method	:new, :create

public

  def allow_name_validation
    return true
  end

  def match?(other_attrs)
    result = false
    result = self.name == other_attrs[:name] if (other_attrs and other_attrs.has_key?(:name))
    return result
  end

  def to_s
    return name
  end

  def display
    return to_s
  end

  allow_search_in [ :name ], { :exclude_classes => [ AuthorityRecord ] }

  alias :related_records :documents

  class <<self

	  #
	  # we _must_ skip the reference_roots validation when indexing because it *can*
	  # happen that the authority record actually is not connected to any
	  # documents, thus returning an empty array for +related_records+ and an
	  # empty +reference_roots+
	  #
	  def skip_reference_roots_validation
	    return true
	  end

  end

  include ReferenceRootsHelper
	
end

AR_PATH = 'authority_record/'
require_dependency AR_PATH + 'confirm_delete'
require_dependency AR_PATH + 'display_class_methods'
require_dependency AR_PATH + 'display_instance_methods'
require_dependency AR_PATH + 'variant_forms'
require_dependency AR_PATH + 'variant_methods'
require_dependency AR_PATH + 'date_onchange_strings'
require_dependency AR_PATH + 'crud'
require_dependency AR_PATH + 'adjust_dates'
require_dependency AR_PATH + 'person_name'
require_dependency AR_PATH + 'collective_name'
require_dependency AR_PATH + 'site_name'
require_dependency AR_PATH + 'score_title'

AuthorityRecord.class_eval do
  include AuthorityRecordParts::ConfirmDelete
  include AuthorityRecordParts::DisplayMethods::Base
  include AuthorityRecordParts::VariantForms
  include AuthorityRecordParts::DateOnChangeStrings
  include AuthorityRecordParts::Crud
  include AuthorityRecordParts::AdjustDates
end
