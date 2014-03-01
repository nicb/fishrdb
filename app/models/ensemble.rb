#
# $Id: ensemble.rb 470 2009-10-18 16:18:58Z nicb $
#
class Ensemble < ActiveRecord::Base

  include FinderCreatorHelper

  belongs_to :conductor, :class_name => 'Name'
  belongs_to :creator, :class_name => 'User'
  belongs_to :last_modifier, :class_name => 'User'

  validates_presence_of :name, :creator_id, :last_modifier_id

  def full_name
    result = name
    result += (', ' + conductor.full_name + ', direttore') if conductor
    return result
  end

  class <<self

	  def create_from_form(args = {})
	    iargs = HashWithIndifferentAccess.new(args)
      cargs = iargs.transfer(:creator_id, :last_modifier_id, :creator, :last_modifier)
	    new_args = {}
	    n = i = nil
      if iargs.has_key?(:conductor) && !iargs[:conductor].blank?
        cond_args = iargs.read_and_delete(:conductor)
        obj = cond_args.class.name == 'Name' ? cond_args : Name.find_or_create(cond_args, cargs)
        new_args[:conductor_id] = obj.id
      end
      iargs.update(new_args)
      result = find_or_create(iargs, cargs)
      unless result
        iargs.update(cargs)
        result = create(cargs)
      end
      return result
	  end

  end

end
