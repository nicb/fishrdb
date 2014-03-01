#
# $Id: name.rb 617 2012-07-15 16:30:06Z nicb $
#
# Name is a general base class for all names, which can be used
# with the join class NameReference to link it to documents
#
# NOTE: In a short future, the 'PersonName' authority record,
# instead of carrying directly a name, will have a 'belong_to'
# link to a Name, replacing the actual structure
#
require 'reference_roots_helper'

class Name < ActiveRecord::Base

  include FinderCreatorHelper

  belongs_to :creator, :class_name => 'User'
  belongs_to :last_modifier, :class_name => 'User'

  validates_uniqueness_of :first_name, :scope => [:last_name, :pseudonym, :disambiguation_tag],
      :message => 'Questo nome esiste già', :allow_nil => true, :allow_blank => true

  #
  # one of the two components of the name must be present
  #
  validates_presence_of :last_name, :if => Proc.new { |n| n.first_name.blank? }
  validates_presence_of :first_name, :if => Proc.new { |n| n.last_name.blank? }
  validates_presence_of :creator_id, :last_modifier_id

  def full_name
    return [first_name, pseudonym, last_name, disambiguation_tag].conditional_join(' ')
  end

  alias to_s full_name

	allow_search_in [ :first_name, :last_name, :pseudonym, :full_name ]

  class <<self

    def create_from_form(args = {})
      args = HashWithIndifferentAccess.new(args)
      c_args = args.transfer(:creator_id, :last_modifier_id, :creator, :last_modifier)
      return find_or_create(args, c_args)
    end

		#
		# FIXME: we currently must skip the +reference_roots+ validation because
		# there is no direct connection between +Name+s and related records. This
		# is obviously unacceptable and will be fixed in the future.
		#
		def skip_reference_roots_validation
			true
		end

  end

	include ReferenceRootsHelper
	#
	# the +related_records+ method must be implemented in all subclasses in
	# order for the indexer to work properly.
	#
	# FIXME: currently, the +related_records+ of the +Name+ object returns an
	# empty array. In the future however, when +Name+s and +PersonName+s will be
	# joined together, +Name+ might well behave the way +PersonName+ behaves
	# now.
	#
	def related_records
		[]
	end

end
