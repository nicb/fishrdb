#
# $Id: date_extensions.rb 247 2008-07-20 08:59:10Z nicb $
#
#
# Date extensions
#

class Date

  def to_it
    return self.strftime('%d-%m-%Y')
  end

end
