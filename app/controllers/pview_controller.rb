#
# $Id: pview_controller.rb 615 2012-06-07 21:27:49Z nicb $
#

class PviewController < ApplicationController

	skip_before_filter :require_login

  #
  # show methods
  #
public

  def show
    begin
      @doc = Document.find(params[:id])
    rescue ActiveRecord::RecordNotFound => msg
      flash[:notice] = msg
      @doc = Document.fishrdb_root
    end
    @sidebar_root = sidebar_root(@doc.id)

    render(:action => 'show')
  end

  #
  # index (starter) method
  #
  def index
    session['user'] = User.find_by_login('anonymous')
    @sidebar_root = sidebar_root

    render(:action => 'index')
  end

  #
  # sidebar actions
  #
private

  def open_or_toggle(method)
    args = SidebarTree.send(method, session, params)
    flash[:notice] = args.delete(:message) if args.has_key?(:message)
    args.update(:action => :show)
	  redirect_to args
  end

public

  def toggle
      open_or_toggle(:toggle)
  end

  def open
      open_or_toggle(:open)
  end

private

  include BackofficeSearchHelper::Controller

  def ar_search(st, string_condition = "lower(name) like ?", ar_class = AuthorityRecord)
    results = []
    ars = ar_class.find(:all, :conditions => [string_condition, st])
    ars.each do
      |ar|
      ar.documents.each do
        |d|
        results << d if d.public_visibility
      end
    end
    return results
  end

  def doc_search(st, results = [])
    srs = do_the_search(st, '0')
    srs.each do
      |srd|
      results << srd.document if srd.document.parent && srd.document.public_visibility # avoid tree root
    end
    return results
  end

  class SeriesResult
    attr_accessor :documents
    attr_reader :series

    def initialize(s)
      @series = s
      @documents = []
    end

    def <<(d)
      @documents << d
      @documents.uniq!
    end

  private

    def inflection
      return documents.size > 1 ? 'i' : 'o'
    end

  public

    def series_result_output_string
      result = ''
      if documents.size > 0
        result = documents.size.to_s + ' document' + inflection + ' in '
      end
      return result
    end

    def <=>(other)
      return self.series.name <=> other.series.name
    end

  end

  class SeriesResults < Hash

    attr_reader :logger

    def initialize(l = Rails::logger)
      @logger = l
    end

    def append(s, doc)
      if doc.public_visibility
	      unless self.has_key?(s.name)
	        sr = SeriesResult.new(s)
	        self[s.name] = sr
	      end
	      self[s.name] << doc
      end
    end

    def add_results(r)
      r.each do
        |d|
        begin
          s = d.reference_roots
          s.keys.each do
            |id|
            doc = Document.find(id)
            self.append(doc.reference_series, doc)
          end
        rescue => msg
          n = d.respond_to?(:name) ? d.name : ''
          self.logger.error(">>>> method reference_roots failed for document #{d.class}(\"#{n}\"): #{msg}")
          raise if RAILS_ENV == 'test'
        end
      end
    end

    def values
      return super.sort { |a, b| a <=> b }
    end

    class <<self

		  def organize_by_series(results)
        srs = SeriesResults.new
		
        srs.add_results(results)

        return srs
		  end

    end

  end

  class SearchDisplay
    attr_reader :results, :selected_tab, :search_section, :sidebar_root, :search_term

    def initialize(r, st, ss, term, sr)
      @results = SeriesResults.organize_by_series(r)
      @selected_tab = st
      @search_section = ss
      @search_term = term
      @sidebar_root = sr
    end

    def print
      return self.results.values.map { |sr| sr.series_result_output_string + " <a href=\"##{sr.series.name}\">#{sr.series.name}</a>" }.join(', ')
    end

    def blank?
      return self.results.blank?
    end

  end

public

  #
  # generic search
  #

  def generic_search
    search_term = params[:search][:term]
    results = SearchEngine::Search.search_documents(search_term)

    @display = SearchDisplay.new(results, 'generic', 'generale', search_term, sidebar_root)

    render(:action => :results)
  end

private
  
  def common_init_search(form)
    @sidebar_root = sidebar_root

    render(:action => form)
  end

public

  #
  # tape search
  #

  def tape_init_search
    common_init_search('tape_search_form')
  end

  def tape_search
    search_term = params[:search][:term]
    results = TapeRecord.search_documents(search_term)

    @display = SearchDisplay.new(results, 'tape', 'sui nastri', search_term, sidebar_root) 

    render(:action => :results)
  end

  #
  # score search
  #

  def score_init_search
    common_init_search('score_search_form')
  end

  def score_search
    sterms = params[:search]
    results = []
    id_records = nil
    [['title', 'raw_full_name'], ['author', 'autore_score']].each do
      |k|
      unless sterms[k[0]].blank?
        fo = []
        fo << FindOptionHelper::Condition.new('search_indices.field =', k[1])
        fo << FindOptionHelper::Condition.new('search_indices.record_id in', id_records) if id_records
        results = Score.search_documents(sterms[k[0]], fo)
        id_records = results.map { |si| si.id }
      end
    end

    search_terms = "Autore: " + sterms['author'] + ", Titolo: \"" + sterms['title'] + "\""
    @display = SearchDisplay.new(results, 'score', 'nelle partiture', search_terms, sidebar_root)

    render(:action => :results)
  end

public

  #
  # private archive search
  #

  def private_archive_init_search
    pa = Document.find_by_name('Archivio Privato')
    @series = Document.find(:all,
                            :conditions => ["description_level_id = ?  and parent_id = ?",
                                            DescriptionLevel.serie.id, pa.id ])
    @sidebar_root = sidebar_root

    render(:action => 'archive_search_form')
  end

  def archive_search
    st = params[:search][:term]
    series = FindOptionHelper::ConditionGroup.new('or')
    params['search'].each do
      |k, v|
      if (k =~ /^series_/ and v == 'yes')
        series_id = k.sub(/^series_/,'')
        series << FindOptionHelper::Condition.new('reference_roots like', '%' + series_id + '%')
      end
    end
    opts = [ series, ]
    results = Series.search_documents(st, opts)

    @display = SearchDisplay.new(results, 'archive', "nell'archivio privato", st, sidebar_root)

    render(:action => :results)
  end

  def search_result_details
    ids = params[:collection]
    td = params[:locals][:this_divname]
    docs = []
    ids.each { |id| docs << Document.find(id) }
    
    render(:partial => 'search_result_details', :object => docs, :locals => {:this_divname => td})
  end

  #
  # auto complete text fields
  #
  def auto_complete_for_search_term
    search_term = '%' + params[:search][:term] + '%'
    auto_complete_common(search_term) { |st|  AuthorityRecord.find(:all, :conditions => ["lower(name) like ? or lower(first_name) like ?", st, st]) }
  end

  def auto_complete_for_search_title
    search_term = '%' + params[:search][:title] + '%'
    auto_complete_common(search_term) { |st| ScoreTitle.find(:all, :conditions => ["lower(name) like ?", st]) }
  end

  def auto_complete_for_search_author
    search_term = '%' + params[:search][:author] + '%'
    auto_complete_common(search_term) { |st| PersonName.find(:all, :conditions => ["lower(name) like ?", st]) }
  end

private

  def auto_complete_common(st)
    #
    # let's have at least four chars to search for results
    #
    if st.size >= 4
      results = yield(st)
    end
    render(:partial => 'autocomplete', :object => results)
  end

  def sidebar_root(root_id = Document.fishrdb_root.id)
    return SidebarTree.render(root_id, session, params)
  end

end
