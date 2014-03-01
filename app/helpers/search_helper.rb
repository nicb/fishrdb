#
# $Id: search_helper.rb 83 2007-11-26 11:54:48Z nicb $
#
#
# This is required by the search indexer (perhaps an old version)
#
require 'search/simple'
gem 'SimpleSearch'

module SearchHelper

	module Model
		module ClassMethods
			def find_all
				return self.find(:all)
			end
		end
	end

	module Controller

		class FishrdbSearchResult < Search::Simple::SearchResult

			attr_reader	:column, :context, :search_terms, :document

		private

			def retrieve_context
				return @document.send(@column)
			end

			def self.demangle_name(name)
				return name.split('.')
			end

			def initialize(name, score)
				(classname, pk_id, @column) = FishrdbSearchResult.demangle_name(name)
				@document = classname.constantize.find(pk_id)
				@context = ""
				@search_terms = nil
				super(@document.name, score)
			end

		public

			def id
				return @document.id
			end

			def add_search_terms(terms)
				@search_terms = terms
				@context = retrieve_context.dup
				@search_terms.each do
					|t|
					re = Regexp.new(/#{t}/i, Regexp::EXTENDED, 'U')
					@context.gsub!(re) { |m| "<b><i>#{m}</i></b>" }
				end
			end

			def relevance
				return (Float(score)/Float(@search_terms.size))
			end

			def self.is_record_still_there?(name)
				(classname, pk_id, column) = demangle_name(name)
				return classname.constantize.find(:first, :conditions => ["id = ?", pk_id])
			end
		end

		class Search::Simple::SearchResults
			alias super_add_result add_result 

			def add_result(name, score)
				#
				# the record in question might still be in the index but not
				# present in the database, because in the meantime someone has
				# deleted it and the index has not been rebuilt. So we need to
				# make sure that it is still in the db.
				#
				@results << FishrdbSearchResult.new(name, score) if FishrdbSearchResult.is_record_still_there?(name)
			end

			def found_something?
				#
				# this is a crude hack. But until I really understand how this
				# thing works it seems like the only way to figure out whether
				# the engine has really found something or not
				#
				return self.contains_matches && self.warnings.empty?
			end

		end

private

		def Controller.extract_full_strings(terms)
			results = []
			re = Regexp.new(/["']/)
			start = stop = 0
			while (start = terms.index(re, start)) 
				r = terms.slice(start,terms.size-start)
				if (stop = terms.index(re, start+1))
					r = terms.slice!(start, stop+1)
				end
				results << r.gsub(re, '')
				break unless stop > 0
				start = 0
			end

			return results
		end

public

		def Controller.condition_terms(terms)
			results = Controller.extract_full_strings(terms)
			terms.strip.split(' ').each { |t| results << t }

			return results
		end

		def do_the_search(terms)
			conf = YAML.load(File.open(File.join(RAILS_ROOT,"config","search.yml")))
			return self.send("#{conf['search_backend']}_search", terms, conf)
		end

		#
		# from the doc in SimpleSearch/lib/search/simple/searcher.rb:
		#
		# A word beginning '+' _must_ appear in the target documents
		# A word beginning '-' <i>must not</i> appear
		# other words are scored. The documents with the highest
		# scores are returned first
		#
		def simple_search(terms, conf)

			empty_contents = MockContents.new

			index_filename = File.join(RAILS_ROOT,conf['simple_backend']['index_filename'])

			if not File.exists?(index_filename) then
				raise "Il file indice (#{File.expand_path(index_filename)}) non esiste.  E` stato eseguito scripts/indexer?"
			end

			simple_index = Search::Simple::Searcher.load(empty_contents,index_filename)
			search_terms = Controller.condition_terms(terms)

			# what to return to the caller
			results = Array.new

			search_results = simple_index.find_words(search_terms)

			if search_results.found_something?
				search_results.results.sort.reverse.each do |result|
					result.add_search_terms(search_terms)
					results << result
				end
			#else
			#	flash[:notice] = search_results.warnings
			end

			return results.uniq
		end

	end

end
