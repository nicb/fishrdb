#
# $Id: search.rb 539 2010-09-05 15:53:58Z nicb $
#

require 'search_engine/string_extensions'

module SearchEngine

  module Search

    module SpecializedSearch

	    module ClassMethods
	
	      #
	      # +<Class>.search+ allows to perform a per-class search returning
        # search indexes. It takes a string and optionally an array of
        # FindOption objects
	      #
	
	      def search(string, other_conditions = [])
          return common_search(string, other_conditions) { |s, oc| Search.search(s, oc) }
        end

	      #
	      # +<Class>.search_documents+ allows to perform a per-class search returning
        # full documents. It takes a string and optionally an array of
        # FindOption objects
	      #
        def search_documents(string, other_conditions = [])
          return common_search(string, other_conditions) { |s, oc| Search.search_documents(s, oc) }
        end

      private

        def common_search(string, other_conditions)
          results = []
          unless !string && other_conditions.empty?
		        sic = SearchEngine::SearchIndexClass.find_by_class_name(self.name)
	          if sic
 	            jo = FindOptionHelper::Joins.new(:search_index_class_references)
	            co = FindOptionHelper::Condition.new('search_index_class_references.search_index_class_id =', sic.id)
	            conds = other_conditions.concat([jo, co])
	            results = yield(string, conds)
	          end
          end
          return results
        end
	
	    end

    end

    #
    # +Search::search(string) provides a generalized interface for all
    # searches. It takes a string and optionally an array of FindOption objects
    #

    def Search.search(string, other_conditions = [])
      result = []
      unless (string.is_a?(String) && string.empty?) || (!string && other_conditions.blank?)
        tokens = []
        tokens = Search.tokenize(string) if string
	      find_options = Search.build_condition(tokens)
        other_conditions.each { |oc| find_options << oc }
        begin
	        temp_result = SearchIndex.all(find_options.to_options) unless find_options.blank?
          temp_result.uniq!
          result = temp_result
        rescue => msg
          Rails::logger.error('>>>> ' + msg + " (search term \"#{string}\")")
        end
      end
      #
      # NOTE: for some unknown reason even 'and'ing conditions the search
      # returns multiple identical records. Therefore, we 'uniq' them.
      #
      return result
    end

    #
    # +Search::search_documents(string) returns the documents related to the
    # given string. It takes a string and optionally an array of FindOption objects
    #
    def Search.search_documents(search_term, other_conditions = [])
      results = []

      index_results = SearchEngine::Search.search(search_term, other_conditions)
      unless index_results.blank?
        ids = SearchEngine::Search.group_by_class(index_results)
        ids.each do
          |k, v|
          klass = k.constantize
	        begin
	          temp_results = klass.find(v)
	          results.concat(temp_results)
	        rescue ActiveRecord::RecordNotFound => msg
	          Rails::logger.error("SearchEngine::search_documents failed! Perhaps the engine needs re-indexing? (failure was #{msg})")
	        end
        end
      end

      return results
    end


  private

    #
    # TODO: currently, the search string eliminates any non-alphabetic
    # character, changing it into a space (thus providing a separator).
    # In the future, this should provide literal quote support.
    #
    def Search.tokenize(string)
      cond_string = string.search_engine_cleanse
      tokens = cond_string.split(/\s+/)
      result = tokens.map { |s| s unless s.blank? }.compact
      return result
    end

    def Search.build_condition(tokens)
      result = FindOptionHelper::FindOptions.new
      tokens.each_with_index do
        |t, i|
        next if t.empty?
        s_term = '%' + t + '%'
        result << FindOptionHelper::Condition.new('string like', s_term)
      end
      return result
    end

    #
    # +group_by_class+ groups search result record_ids by reference classes.
    # NOTE: this method requires the reference_ancestor plugin.
    #
    def Search.group_by_class(results)
      result = {}

      results.each do
        |si|
        klasses = si.search_index_classes.map do
          |sic|
          klass = sic.class_name.constantize
          klass.reference_ancestor
        end.uniq
        klasses.each do
          |kl|
          cname = kl.name
          result.update(cname => [] ) unless result.has_key?(cname)
          result[cname] << si.record_id
        end
      end

      result.values.each { |v| v.uniq! }

      return result
    end

  end

end
