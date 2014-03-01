#
# $Id: file_extensions.rb 399 2009-05-05 00:42:33Z nicb $
#

class File

  class << self

    def size_in_mb(filename)
	    result = ''
	    result = sprintf("%.2f Mb", (size(filename).to_f/1.megabyte.to_f)) if exists?(filename)
	    return result
    end

  end

end
