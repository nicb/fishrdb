#
# $Id: info.rb 555 2010-09-12 19:53:28Z nicb $
#
require 'file_extensions'

module TapeNameCaption

  module Info

    include TapeNameCaption::Constants

    def size
      return File.size_in_mb(File.join(RAILS_ROOT, self.full_filename))
    end

  end

end
