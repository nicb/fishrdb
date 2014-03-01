#
# $Id: bundle_file.rb 572 2010-12-12 18:37:32Z nicb $
#
require 'ftools'

module BundleGenerator

  class BundleFile < Base

    attr_reader :path

    def initialize(p)
      super(nil)
      @path = p
    end

	  def copy(dest)
	    File.copy(self.path, dest)
      self.dot
	  end

  end

  class TapeFile < BundleFile; end

  class ImageFile < BundleFile; end

  class MetaFile < BundleFile; end

end
