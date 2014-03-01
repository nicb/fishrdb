#
# $Id: other_tests.rake 614 2012-05-11 17:25:14Z nicb $
#

namespace :test do

  namespace :other do

    namespace :importers do

		  Rake::TestTask.new(:cd => 'db:test:prepare') do |t|
		    t.libs << 'test'
		    t.pattern = 'lib/cd_importer/test/**/*_test.rb'
		    t.verbose = true
		  end
      Rake::Task['test:other:importers:cd'].comment = 'Run tests for importing cds'

		  Rake::TestTask.new(:tape => 'db:test:prepare') do |t|
		    t.libs << 'test'
		    t.pattern = 'lib/tdp/tape/test/**/*_test.rb'
		    t.verbose = true
		  end
      Rake::Task['test:other:importers:tape'].comment = 'Run tests for importing tapes'

    end

	  desc 'Run all importers tests'
    task :importers => %w(importers:cd importers:tape)
	
	  Rake::TestTask.new(:bundle_generator => 'db:test:prepare') do |t|
	    t.libs << 'test'
	    t.pattern = 'lib/bundle_generator/test/**/*_test.rb'
	    t.verbose = true
	  end
	  Rake::Task['test:other:bundle_generator'].comment = 'Run bundle generator tests'
	
	  Rake::TestTask.new(:mp3_helper => 'db:test:prepare') do |t|
	    t.libs << 'test'
	    t.pattern = 'lib/mp3_helper/test/**/*_test.rb'
	    t.verbose = true
	  end
	  Rake::Task['test:other:mp3_helper'].comment = 'Run mp3 helper tests'

  end

  desc 'Runs all "other" tests (bundle_generations, mp3_helper, etc.)'
  task :other => %w(other:importers other:bundle_generator other:mp3_helper)

  #
  # These tasks were stolen from a 2.3.4 distribution
  # Please FIXME: remember to remove them when upgrading to a new rails version
  #

  Rake::TestTask.new(:benchmark => 'db:test:prepare') do |t|
    t.libs << 'test'
    t.pattern = 'test/performance/**/*_test.rb'
    t.verbose = true
    t.options = '-- --benchmark'
  end
  Rake::Task['test:benchmark'].comment = 'Benchmark the performance tests'

  Rake::TestTask.new(:profile => 'db:test:prepare') do |t|
    t.libs << 'test'
    t.pattern = 'test/performance/**/*_test.rb'
    t.verbose = true
  end
  Rake::Task['test:profile'].comment = 'Profile the performance tests'

end
