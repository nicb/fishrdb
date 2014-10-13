#
# $Id: fishrdb.rake 565 2010-11-28 19:53:45Z nicb $
#
# require 'debugger' # when debugging

namespace :fishrdb do

  desc "Install FISHrdb (defailt RAILS_ENV: production, if not set)"
  task  :install do

    require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'installer'))
    Installer::Runner.install

  end

  desc "Uninstall FISHrdb"
  task  :uninstall do

    require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'installer'))
    Installer::Runner.uninstall

  end

	namespace :stats do

		desc 'Calculate document statistics for FIShrdb'
		task :document_count => [ :environment ] do

      require File.expand_path(File.join(['..'] * 3, 'lib', 'fishrdb', 'stats'), __FILE__)

			Fishrdb::Stats::DocumentHierarchicalCount.count

		end

	end

end
