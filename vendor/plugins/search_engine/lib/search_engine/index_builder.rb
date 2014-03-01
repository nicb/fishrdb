#
# $Id: index_builder.rb 617 2012-07-15 16:30:06Z nicb $
#

require 'search_engine/string_extensions'

module SearchEngine

  module IndexBuilder

    class Builder

      class <<self

			  def build(filter = [])
          ActiveRecord::Base.transaction do
			      clean_slate
				    Manager.searchable_objects(filter).each do
				      |sok|
              Rails::logger.info(">>>> Creating indexes for #{sok.name} (methods: #{sok.search_engine_fields.map { |sef| sef.to_s }.join(', ')})")
				      coll = sok.all
				      coll.each do
				        |obj|
				        if obj.included_in_indexing?
				          obj.class.search_engine_fields.each do
				            |sf|
                    #
                    # we will avoid indexing methods that return empty results
                    #
                    unless obj.send(sf).blank?
		                  #
		                  # if one index creation fails we still don't want to
		                  # interrupt the whole indexing process, but we log it.
		                  #
		                  begin
					              si = index(obj, sf)
	                      raise("Search Index not created for method #{sf}") unless si
	                      raise("Search Index invalid  for method #{sf} (#{si.errors.full_messages.join(', ')})") unless si && si.valid?
		                  rescue => msg
		                    Rails::logger.error(">>>> Failed to create search index for #{obj.class.name}(#{obj.id}, \"#{obj.name}\"): #{msg}")
		                  end
                    end
				          end
				        end
				      end
				    end
          end
			    return SearchEngine::SearchIndex.count
			  end

     private

			  #
			  # NOTE: +clean_slate+ cannot be tested directly because it is
			  # (and should remain) private.
			  #
			  # NOTE: for efficiency and other reasons (notably the reset of indexes),
			  # +clean_slate+ does some
			  # inherently non-portable calls for MySQL. So there's a portable (albeit
			  # slower) version provided too when MySQL is not being used (such as in
        # when SQLite is used in testing).
			  #
			  def clean_slate
			    Rails::logger.info('>>>>> REBUILDING SEARCH ENGINE INDEX')
          an = ActiveRecord::Base.connection.adapter_name
          case an
          when 'MySQL' then clean_slate_mysql
          when 'SQLite' then clean_slate_sqlite
          else clean_slate_portable
			    end
          clean_slate_common
			  end

			  def clean_slate_mysql
			    SearchIndexClassReference.connection.execute('TRUNCATE TABLE search_index_class_references;')
			    SearchIndexClass.connection.execute('TRUNCATE TABLE search_index_classes;')
			    SearchIndex.connection.execute('TRUNCATE TABLE search_indices;')
			    SearchIndex.connection.execute('ALTER TABLE search_indices AUTO_INCREMENT = 0;')
			    SearchIndexClass.connection.execute('ALTER TABLE search_index_classes AUTO_INCREMENT = 0;')
			  end

			  def clean_slate_portable
			    [SearchIndex, SearchIndexClass, SearchIndexClassReference].each { |klass| klass.delete_all }
			  end

        def clean_slate_sqlite
          clean_slate_portable
          #
          # the next two lines are needed to reset the increment counter
          #
          SearchIndex.connection.execute('DELETE FROM sqlite_sequence WHERE name = "search_indices";')
          SearchIndex.connection.execute('DELETE FROM sqlite_sequence WHERE name = "search_index_classes";')
        end

        def clean_slate_common
			    @@number_of_created_tokens = 0
        end

			  def index(obj, search_field)
			    result = nil
			    string = obj.send(search_field).to_s.search_engine_cleanse
		      result = SearchIndex.index(obj, search_field, string) unless string.blank?
			    return result
			  end

      end

    end

  end

end
