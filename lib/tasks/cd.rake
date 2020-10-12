#
# $Id: cd.rake 448 2009-09-27 23:09:50Z nicb $
#
require File.expand_path(File.join(['..'] * 3, 'config', 'constants'), __FILE__)

namespace :db do
  namespace :cd do
    require File.dirname(__FILE__) + '/../cd_importer'

	  desc "Create all ActiveRecord CD records listed in \"#{CdImporter::Importer::DATA_FILE.sub(RAILS_ROOT + '/lib/cd_importer/../../','')}\" and insert them in db"
	  task :create => :environment do

      require 'document'

      cdiw = CdImporter::Wrapper.new
      cdiw.import

	  end

	  desc "Drop all ActiveRecord CD records from db"
	  task :drop => :environment do

      require 'document'

      cdr = CdRecord.cd_root
      cdr.children(true).each { |c| c.delete_from_form }

    end
  end
end
