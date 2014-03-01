#
# $Id: index_rebuild.rb 539 2010-09-05 15:53:58Z nicb $
#

module SearchEngine

  module Test

    module Utilities

      module IndexRebuild

	      def rebuild_search_index(filter = [])
	        return SearchEngine::IndexBuilder::Builder.build(filter)
	      end
	
	      def rebuild_search_index_if_needed(filter = [])
	        sz = SearchEngine::SearchIndex.all.size
	        rebuild_search_index(filter) unless sz > 0
	      end
	
	      def rebuild_search_index_without_mocks_if_needed
	        sz = SearchEngine::SearchIndex.all.size
	        msic = SearchEngine::SearchIndexClass.all.map { |sic| sic.class_name }.grep(/Mock/)
          other = SearchEngine::SearchIndexClass.all.delete(msic)
	        rebuild_search_index unless (sz > 0 && msic.size == 0)
	      end

      end

    end

  end

end
