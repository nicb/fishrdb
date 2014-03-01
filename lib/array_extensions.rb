#
# $Id: array_extensions.rb 270 2008-11-09 12:06:14Z nicb $
#
# Adds a few convenient methods to the Array class
#

class Array

  def conditional_join(j_s)
    a_copy = self.dup
    a_copy.delete('')
    a_copy = a_copy.compact
    return a_copy.join(j_s)
  end

end
