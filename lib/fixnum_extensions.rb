#
# $Id: fixnum_extensions.rb 459 2009-10-06 07:20:36Z nicb $
#

class Fixnum

private

  def to_var_s(lz)
    return sprintf("%0*d", lz, self)
  end

public

  def to_sss
    return to_var_s(3)
  end

  def to_ssss
    return to_var_s(4)
  end

end
