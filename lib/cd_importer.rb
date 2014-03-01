#
# $Id: cd_importer.rb 446 2009-09-25 04:20:25Z nicb $
#

module CdImporter

  BASE_DIR=File.dirname(__FILE__) + '/cd_importer'

end

$:.unshift(CdImporter::BASE_DIR)

require 'importer'
require 'wrapper'
