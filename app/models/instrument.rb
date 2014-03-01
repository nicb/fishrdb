#
# $Id: instrument.rb 462 2009-10-12 01:07:40Z nicb $
#
class Instrument < ActiveRecord::Base

  include FinderCreatorHelper

  belongs_to :creator, :class_name => 'User'
  belongs_to :last_modifier, :class_name => 'User'

  validates_presence_of :name, :creator_id, :last_modifier_id
  validates_uniqueness_of :name

  def initialize(args = {})
    args[:name] = args[:name].titleize if args && args.has_key?(:name)
    super(args)
  end

  class <<self

    alias_method :create_from_form, :create

  end

end
