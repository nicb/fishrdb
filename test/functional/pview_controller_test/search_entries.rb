#
# $Id: search_entries.rb 626 2012-12-15 11:37:30Z nicb $
#

class PviewControllerTest < ActionController::TestCase

private

  require 'search_engine'
  require 'search_engine/../../test/utilities/index_rebuild'
  require 'find_option_helper'

	class SearchEntry
	  attr_reader :search_term
	
	  def initialize(st)
	    @search_term = st
	  end
	
	  def generate_summary_string
	    results = SearchEngine::Search.search(search_term)
	    return generate_summary_string_common(results)
	  end
	
	  def result_size
	    return SearchEngine::Search.search(search_term).size
	  end

    def sequel
      return ''
    end

    def blank?
      return self.search_term.blank?
    end
	
    include Test::Unit::Assertions
    include ActionController::Assertions

    REF_SPAN = 'span.content_area_title'
    REF_DIV  = 'div.series_search_result_list'

	  def rip_text_out_of_css(element)
	    result = []
	    self.class._rip_text_out_of_css(element, result)
	    return result.join(' ').strip
	  end

    def perform_search(num)
	    sel = self.blank? ? REF_SPAN : REF_DIV
	    el_array = yield(self, sel)
      assert_select(el_array.first, sel, generate_summary_string, "For search term(#{num}): \"#{search_term}\" (should have been: \"#{generate_summary_string}\", was instead \"#{rip_text_out_of_css(el_array)}\"#{sequel})")
    end

	  class << self

      include SearchEngine::Test::Utilities::IndexRebuild
      include Test::Extensions

		  def generate_random_search_entries(num = 10)
		    results = []
 		    rebuild_search_index_without_mocks_if_needed
		    sz = SearchEngine::SearchIndex.all.size
		    results << new('') # empty test case
		    1.upto(num-1) do
		      rnd_idx = random_index(sz, 1)
		      si = SearchEngine::SearchIndex.find(rnd_idx)
		      raise("Generated invalid search index for #{rnd_idx}") unless si.valid?
          str = conditioned_search_term(si.string)
		      se = new(str)
		      results << se
		    end
		    return results
		  end

		  def common_search_preamble
		    result = []
		    num_searches = ENV['PVIEW_SEARCH_NUM_TESTS'] ? ENV['PVIEW_SEARCH_NUM_TESTS'].to_i : 15
 		    rebuild_search_index_without_mocks_if_needed
		    unless ENV['PVIEW_SEARCH_TERM']
		      result = generate_random_search_entries(num_searches)
		    else
		      result << new(ENV['PVIEW_SEARCH_TERM'])
		    end
		    return result
		  end

	    def common_search
	      sentries = common_search_preamble
		    sentries.each_with_index do
		      |se, idx|
          begin
            se.perform_search(idx + 1) { |search, sel| yield(search, sel) }
		        subtest_finished
          rescue NullResponse => msg
            Rails::logger.debug(">>>> common_search failure: #{msg}")
          end
		    end
	    end

		  def _rip_text_out_of_css(s, r)
		    s.each do
		      |tag|
		      r << tag.content if tag.class == HTML::Text
		      _rip_text_out_of_css(tag.children, r)
		    end
		  end

    protected

      def random_index(sz, offset = 0)
        return ((rand()*sz).floor) + offset
      end

      def conditioned_search_term(s)
        result = s
        strsize = s.size
        if strsize > 10
          begin
				    ssstart = (rand()*((strsize-1)/2.0)).round
				    ssslength = (rand()*(strsize-ssstart)).floor
				    sssend = ssstart + ssslength
		        tmpresult = s.slice(ssstart..sssend)
	          #
	          # make sure no Multibyte character gets caught in the middle
	          #
	          newstart = (tmpresult[0] > 127 && tmpresult[1] <= 127) ? 1 : 0
	          newend   = (tmpresult[-1] > 127 && tmpresult[-2] <= 127) ? -2 : -1
	          tmpresult = tmpresult.slice(newstart..newend)
            result = tmpresult
          rescue => msg
            Rails::logger.debug(">>>> conditioned search term raised an exception (#{msg}) - returning #{result}.")
          end
        end
        return result
      end
	
	  end
	
	private
	
	  def generate_summary_string_common(results)
	    result = 'La ricerca non ha prodotto alcun risultato.'
	    unless results.blank?
		    sh = organize_by_series(results)
		    summary_string_header = "Trovati: "
		    doc_strings = []
		    sh.each do
          |h|
          k = h[:series].name
          v = h[:documents]
		      doc_strings << "#{v.size} document#{inflect(v.size)} in  #{k.to_s}"
		    end
		    result = summary_string_header + doc_strings.join(', ') + '.'
	    end
	    return result
	  end
	
	  def inflect(num)
	    return num == 1 ? 'o' : 'i'
	  end
	
	  def organize_by_series(results)
	    series_hash = {}
      docs = []
	
	    results.each do
	      |si|
	      k = si.search_index_classes.first.class_name.constantize
	      d = k.find(si.record_id)
	      docs.concat(d.related_records)
      end
      docs.uniq!
        
      docs.each do
        |d|
	      found_series = d.reference_roots
	      found_series.each do
	        |k, v|
          s = Document.find(v)
          raise(ActiveRecord::RecordInvalid, "Series Document \"#{s.name}\" is invalid (#{s.errors.full_messages.join(', ')})" ) unless s.valid?
	        unless series_hash.has_key?(s.name)
	          series_hash[s.name] = { :series => s, :documents => [ d ] }
	        else
	          series_hash[s.name][:documents] << d
	        end
	      end
      end
      #
      # NOTE: this sort depends on the PviewController::SeriesResult#<=>,
      # which is a private class and cannot be used directly; so it must be
      # kept in sync with that
      #
	    return series_hash.values.sort { |a, b| a[:series].name <=> b[:series].name }
	  end
	
	end
	
	class ClassSearchEntry < SearchEntry
	  attr_reader :klass
	
	  def initialize(st, k)
	    @klass = k
	    return super(st)
	  end
	
	  def generate_summary_string
	    results = self.klass.search(search_term)
	    return generate_summary_string_common(results)
	  end
	
	  class << self
	
		  def generate_random_search_entries(k, num = 10)
		    raise("#{k.name} class cannot be searched") unless k.respond_to?(:search_engine_fields)
		    k_indices = k.all.map { |d| d.id }
		    sz = k_indices.size
		    results = []
		    results << new('') # empty test case
		    idx = 1
		    while (idx < num)
		      rnd_idx = random_index(sz)
		      d = k.find(k_indices[rnd_idx])
		      raise("Invalid class #{d.class.name}") unless d.valid?
		      next unless d.related_records.size > 0
		      sef = d.class.search_engine_fields
		      rnd_fld = (rand()*sef.size-1).floor
		      string = d.send(sef[rnd_fld]).to_s
          str = conditioned_search_term(string)
		      next unless str.size > 1
		      se = new(str)
		      results << se
		      idx += 1
		    end
		    return results
		  end
	
	  end
	
	end

  class TapeRecordSearchEntry < ClassSearchEntry

    def initialize(st)
      return super(st, TapeRecord)
    end

    class << self

      def generate_random_search_entries(num = 10)
        return super(TapeRecord, num)
      end

    end

  end
	
	class ScoreSearchEntry < ClassSearchEntry
	  attr_reader :author
	
	  def initialize(title, a)
	    @author = a
	    return super(title, Score)
	  end
	
	  def generate_summary_string
	    results = []
	    results = klass.search(self.search_term, [FindOptionHelper::Condition.new('field =', 'raw_full_name')]) unless self.search_term.blank?
	    unless self.author.blank?
	      fo =  [ FindOptionHelper::Condition.new('field =', 'autore_score') ]
	      fo <<   FindOptionHelper::Condition.new('record_id in', results.map { |si| si.record_id }) unless results.blank?
	      results = klass.search(self.author, fo)
	    end
	    return generate_summary_string_common(results)
	  end
	
    def blank?
      return self.search_term.blank? && self.author.blank?
    end
	
	  class << self
	
		  def generate_random_search_entries(num = 10)
		    raise("Score class cannot be searched") unless Score.respond_to?(:search_engine_fields)
		    k_indices = Score.all.map { |d| d.id }
		    sz = k_indices.size
		    results = []
		    idx = 0
		    while (idx < num)
		      rnd_idx = random_index(sz)
		      d = Score.find(k_indices[rnd_idx])
		      raise("#{d.class.name} is invalid") unless d.valid?
		      next unless d.related_records.size > 0
		      sterms = [ '', '' ]
		      [:name, :autore_score].each_with_index do
		        |set, idx2|
		        string = d.send(set).to_s
            str = conditioned_search_term(string)
		        sterms[idx2] = str
		      end
		      se = new(sterms[0], sterms[1])
		      results << se
		      idx += 1
		    end
		    return results
		  end
	
	  end
	
	end

	class ArchiveSearchEntry < ClassSearchEntry
	  attr_reader :series_terms
	
	  def initialize(term, s)
	    @series_terms = s
	    return super(term, Series)
	  end

    def series_term_ids
      return self.class.series_term_ids(self.series_terms)
    end

    def selected_serie_names
      series = Document.find(self.series_term_ids)
      return series.map { |s| s.name }.join(', ')
    end

    def sequel
      return " for series \"#{self.selected_serie_names}\""
    end

	  def generate_summary_string
	    results = []
      unless self.search_term.blank?
        sub = FindOptionHelper::ConditionGroup.new('or')
        self.series_term_ids.each { |id| sub << FindOptionHelper::Condition.new('reference_roots like', '%' + id.to_s + '%') }
	      results = klass.search(self.search_term, [sub])
	    end
	    return generate_summary_string_common(results)
	  end
	
	  class << self
	
		  def generate_random_search_entries(num = 10)
		    raise("Series class cannot be searched") unless Series.respond_to?(:search_engine_fields)
		    results = []
        results << new('', generate_empty_series_term)
		    idx = 1
		    while (idx < num)
          s_terms = generate_series_term
          s_terms_ids = series_term_ids(s_terms)
          next if s_terms_ids.blank?
          cog = FindOptionHelper::ConditionGroup.new('or')
          cog << FindOptionHelper::Condition.new('parent_id in', s_terms_ids)
          fopts = FindOptionHelper::FindOptions.new
          fopts << cog
		      k_indices = Series.all(fopts.to_options).map { |d| d.id }
		      sz = k_indices.size
		      rnd_idx = random_index(sz)
		      d = Series.find(k_indices[rnd_idx])
		      raise("#{d.class.name} is invalid") unless d && d.valid?
		      next unless d.related_records.size > 0
          sef = d.class.search_engine_fields
		      rnd_fld = (rand()*sef.size-1).floor
		      string = d.send(sef[rnd_fld]).to_s
          str = conditioned_search_term(string)
		      next unless str.size > 1
          se = new(str, s_terms)
		      results << se
		      idx += 1
		    end
		    return results
		  end

      def series_term_ids(sterm)
        result = []
        sterm.each { |k, v| result << k.sub(/^series_/,'') if v == 'yes' }
        return result
      end

    private

      def common_generate_series_term
	      parent = Folder.find_by_name('Fondo Privato')
	      series = Document.all(:conditions => ["description_level_id = ? and parent_id = ?", DescriptionLevel.serie.id, parent.id])
				raise(RuntimeError, "Parent document \"#{parent.name}\" has no Series documents among its children") if series.blank?
        result = {}
	      series.each do
          |s|
          val = yield(s)
          result.update('series_' + s.id.to_s => val)
        end
        return result
	    end

      def generate_series_term
        return common_generate_series_term { val = (rand() > 0.5) ? 'yes' : 'no' }
      end
	
      def generate_empty_series_term
        return common_generate_series_term { val = 'no' }
      end

    end

  end

end
