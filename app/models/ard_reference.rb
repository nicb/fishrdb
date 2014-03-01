#
# $Id: ard_reference.rb 637 2013-09-10 12:56:40Z nicb $
#
class ArdReference < ActiveRecord::Base

  belongs_to :document
  belongs_to :creator, :class_name => 'User'
  belongs_to :last_modifier, :class_name => 'User'

  validates_presence_of :document_id
  validates_presence_of :authority_record_id
  validates_presence_of :creator_id
  validates_presence_of :last_modifier_id

  #
  # the parent should not be created by itself
  #
  private_class_method  :new, :create
end

class PersonNameArdReference < ArdReference
  belongs_to :person_name, :foreign_key => 'authority_record_id'
  public_class_method :new, :create
end

class SiteNameArdReference < ArdReference
  belongs_to :site_name, :foreign_key => 'authority_record_id'
  public_class_method :new, :create
end

class CollectiveNameArdReference < ArdReference
  belongs_to :collective_name, :foreign_key => 'authority_record_id'
  public_class_method :new, :create
end

class ScoreTitleArdReference < ArdReference
  belongs_to :score_title, :foreign_key => 'authority_record_id'
  public_class_method :new, :create
end
