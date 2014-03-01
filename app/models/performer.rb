#
# $Id: performer.rb 470 2009-10-18 16:18:58Z nicb $
#
class Performer < ActiveRecord::Base

  include FinderCreatorHelper

  belongs_to :name
  belongs_to :instrument
  belongs_to :creator, :class_name => 'User'
  belongs_to :last_modifier, :class_name => 'User'

  validates_presence_of :name_id, :instrument_id

  class <<self

    def create_from_form(args = {})
      iargs = HashWithIndifferentAccess.new(args)
      cargs = iargs.transfer(:creator_id, :last_modifier_id, :creator, :last_modifier)
      new_args = {}
      n = i = nil
      [:name, :instrument].each do
        |k|
        klass = k.to_s.camelcase.constantize
	      if iargs.has_key?(k) && !iargs[k].blank?
	        nargs = iargs.read_and_delete(k)
          obj = nargs.class.name == klass.name ? nargs : klass.find_or_create(nargs, cargs)
	        new_args[(k.to_s + '_id').intern] = obj.id
	      end
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
