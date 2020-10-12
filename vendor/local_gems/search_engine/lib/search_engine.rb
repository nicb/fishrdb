# SearchEngine
#
# $Id: search_engine.rb 539 2010-09-05 15:53:58Z nicb $
#

require 'search_engine/manager'
require 'search_engine/index_system'
require 'search_engine/search_index'
require 'search_engine/search'

class ActiveRecord::Base

  include SearchEngine::IndexSystem
  extend  SearchEngine::Search::SpecializedSearch::ClassMethods

end
