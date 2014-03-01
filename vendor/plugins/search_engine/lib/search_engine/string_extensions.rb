#
# $Id: string_extensions.rb 539 2010-09-05 15:53:58Z nicb $
#
require 'string_extensions'

class String

  def search_engine_cleanse
    return self.cleanse.strip
  end

end
