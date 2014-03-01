#
# $Id: test_search_index.rake 617 2012-07-15 16:30:06Z nicb $
#

namespace :search do

  namespace :index do

		namespace :test do

    	desc "(Re)-build search index for the test environment"
   		task :create => :environment do

				if RAILS_ENV == 'test'
						Rake::Task['db:fixtures:load'].invoke
						Rake::Task['search:index:create'].invoke
				else
					raise(StandardError, "This task must be performed on a 'test' environment (environment is currently: '#{RAILS_ENV}')")
				end

			end

    end

  end

end
