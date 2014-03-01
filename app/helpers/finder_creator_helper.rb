#
# $Id: finder_creator_helper.rb 470 2009-10-18 16:18:58Z nicb $
#
# Finder/Creator helper: this module factorizes all find_or_create functions
# by building one as needed when it is needed
#

module FinderCreatorHelper

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

  public

    def find_or_create(find_args = {}, create_args = {})
      result = nil
      unless find_args.blank_values?
	      finder = build_method_name(find_args)
	      unless finder.blank?
	        args = find_args.dup
	        args.update(create_args)
	        result = send(finder, args)
	      end
      end
      return result
    end

  private

    def build_method_name(args)
      result = ''
#     args.each { |k, v| args.delete(k) if v.blank? } # remove blank items
      unless args.blank?
        result = 'find_or_create_by_' + args.keys.map { |k| k.to_s }.join('_and_')
      end
      return result
    end

    def verify_blanks(args)
      result = args.dup
      filled = false
      result.each do
        |k, v|
        filled = true unless v.blank?
      end
    end

  end

end
