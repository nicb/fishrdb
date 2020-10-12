#
# $Id: info.rb 555 2010-09-12 19:53:28Z nicb $
#
require File.expand_path(File.join(['..'] * 6, 'lib', 'file_extensions'), __FILE__)

module TapeNameCaption

  module Info

    include TapeNameCaption::Constants

    def size
      return File.size_in_mb(File.join(RAILS_ROOT, self.full_filename))
    end

  end

end
