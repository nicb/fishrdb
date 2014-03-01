#
# $Id: backoffice_search_helper.rb 286 2009-01-19 00:07:56Z nicb $
#
# The backoffice search helper is  a  straight  forward  Document.find()
# call with specific conditions. This is used as  a  first  searcher  to
# help archivers out when they have  just  added  some  items  into  the
# database. The user search should use the SearchHelper  module  (index-
# based engine).
#

module BackofficeSearchHelper

	module Model

		class SearchTerm
			attr_reader :item

			FIELDS = %w(name description data_topica organico_score
				edizione_score luogo_edizione_score trascrittore_score note
				anno_composizione_score anno_edizione_score tipologia_documento_score
        autore_score misure_score
				autore_versi_score)

			def initialize(st)
				@item = st
			end

			def search_condition
				wrapped = []
				FIELDS.each do
					|f|
					wrapped << "(#{f} like '%#{@item}%')"
				end
				return "(" + wrapped.join(" or ") + ")"
			end

			def to_s
				return @item
			end
		end

		class SearchResult

			attr_reader	:document, :relevance, :search_terms

		private

			def initialize(document, search_terms, score = 1)
				@document = document
				@search_terms = search_terms
				@relevance = score
			end

			def calculate_relevance
				result = 0
				@search_terms.each do
					|st|
					re = Regexp.new(/#{re}/i, Regexp::EXTENDED, 'U')
					SearchTerm::FIELDS.each do
						|c|
						string = @document.send(c)
						start = 0
						while (start < string.length)
							if start = (string[start+1..string.length] =~ re)
								result = result + 1
							else
								break
							end
						end
					end
				end
				return result
			end

		public

			def id
				return @document.id
			end

			def name
				return @document.name
			end

			def context(term)
				re = Regexp.new(/#{term.item}/i, Regexp::EXTENDED, 'U')
				result = ''
				SearchTerm::FIELDS.each do
					|c|
					string = @document.send(c)
					if string =~ re
						result = @document.send(c).sub(re) { |m| "<b><i>#{m}</i></b>" }
					end
					break unless result.empty?
				end
				return result
			end

			def relevance
				# return calculate_relevance # this doesn't work yet
				return 1
			end
		end
	end

	module Controller

	private

		def Controller.next_token(string, regexp)
			string = string.strip
			next_stop = string.index(regexp)
			if next_stop
				sep, token, rest = string[next_stop..next_stop], string[0..next_stop-1], string[next_stop+1..string.length]
			else
				sep, token, rest = nil, string, ''
			end
			return sep, token, rest
		end

		def Controller.parse_search_string(terms_string) 
			result = []
			input_string = terms_string.strip
			re = Regexp.new(/(["']|\s+)/)
			re_quotes = Regexp.new(/["']/)
			start = stop = 0
			while (!input_string.empty?)
				separator, token, input_string = next_token(input_string, re)	
				if separator =~ re_quotes
					separator, token, input_string = next_token(input_string, separator)
				end
				result << Model::SearchTerm.new(token)
			end
			return result
		end

		def Controller.build_subtree(root_id)
			return Document.find(root_id).with_descendants.map { |d| d.id }
		end

		def Controller.ancestor_conditions(root)
			return nil unless root != 0
			subtree = build_subtree(root).map { |id| "parent_id = #{id}" }.join(" or ")
			return "(" + subtree + ")"
		end

		def Controller.build_conditions(terms, root)
			result = terms.map { |t| t.search_condition }.join(" and ")
			ac = ancestor_conditions(root.to_i)
			if ac
				result = result + " and " + ac
			end
			return result
		end

	public
		#
		# Search terms are and-ed together
		# Words in quotes are searched together
		#
		def do_the_search(string, root)
			terms = Controller.parse_search_string(string)
			search_conditions = Controller.build_conditions(terms, root)
			docs = Document.find(:all, :conditions => search_conditions, :order => 'position')
			return docs.map { |d| Model::SearchResult.new(d, terms) }
		end

	end

end
