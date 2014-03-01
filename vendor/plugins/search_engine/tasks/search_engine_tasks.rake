#
# $Id$
#
require 'debugger' if RAILS_ENV == 'test'

$: << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join('search_engine', 'index_builder')

namespace :search do

  namespace :index do

    desc "(Re)-build search index"
    task :create => :environment do

      SearchEngine::IndexBuilder::Builder.build

    end
  end

end
