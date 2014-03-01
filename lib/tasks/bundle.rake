#
# $Id: bundle.rake 577 2010-12-15 01:26:21Z nicb $
#

namespace :fishrdb do

  namespace :bundle do

	  desc "Create a material bundle interactively (default RAILS_ENV=production, if not set)"
	  task :create => :environment do

      require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'bundle_generator'))
      BundleGenerator::Driver.interactive

	  end

  end

end
