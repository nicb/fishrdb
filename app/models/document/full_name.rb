#
# $Id: full_name.rb 327 2009-03-09 21:34:37Z nicb $
#
# The +full_name+ method collates the :name_prefix and :name properties so
# that they do display correctly.
#

module DocumentParts

  module FullName

	  def full_name
	    return [name_prefix, name].conditional_join(' ')
	  end

  end

end
