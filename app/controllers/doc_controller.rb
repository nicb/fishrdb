#
# $Id: doc_controller.rb 619 2012-09-23 15:59:12Z nicb $
#

require_dependency 'array_extensions'
require_dependency 'fixnum_extensions'

class DocController < ApplicationController

	include DocHelper
	include CrudHelper
	include BackofficeSearchHelper::Controller
	include RailsbenchHelper # needed to support railsbench under rails2.0

  caches_action :doc
  cache_sweeper	:document_sweeper

private

  def final_page_number(the_doc, pars)
    page = 1
    if pars['page']
      page = pars['page']
    else
      if the_doc.no_children?
        page = the_doc.my_page(per_page)
      end
    end
    return page
  end

	def render_doc_object(the_doc, pars = {})
    unless session_user
      redirect_to(:controller => 'account', :action => 'login')
      return
    end
		@doc = the_doc
    if @doc.no_children?
      @tree_root = @doc.parent
    else
      @tree_root = @doc
    end
    @page = final_page_number(@doc, pars)
		func = pars[:method] ? pars[:method] : :render
    raise "@doc is nil for #{the_doc.name}(#{the_doc.id})" unless @doc
    raise "@tree_root is nil for #{the_doc.name}(#{the_doc.id})" unless @tree_root
		if @doc.id == @tree_root.id
			remember_last(@doc.id)
		else
			remember_last(@doc.id, @doc.parent.id)
		end
		options = { :action => 'show', :id => @doc.id, :page => @page }
		#
		# FIXME: the next lines have been commented out because once the filter is
		# removed, it does not seem to be possible to reinstall the filter chain.
		# This breaks some security places in which filters are useful.
		# Furthermore, all regression tests pass even if this code is removed, so
		# it does not seem to be too useful :( Do remove it once it is safe to do
		# so.
		#
    # if func == :redirect_to
    #   DocController.skip_filter(DocController.filter_chain())
    # end
		self.send(func, options)
	end

  def make_sure_its_an_object(id_or_obj)
    return id_or_obj.is_a?(Document) ? id_or_obj : Document.find(id_or_obj)
  end

	def render_doc(id_or_obj, options = {})
    begin
      the_doc = make_sure_its_an_object(id_or_obj)
# 	  options[:page] = options[:page] ? options[:page] : page_number(the_doc)
      render_doc_object(the_doc, options)
    rescue ActiveRecord::RecordNotFound
#logger.info("====> render_doc(#{id_or_obj}, #{options.inspect}) - ActiveRecord::RecordNotFound rescue hit - last_tree_visited = #{last_tree_visited.inspect}")
		  rescue_redirect("Il record #{id_or_obj} non esiste (più) nel database")
    end
	end

	def redirect_to_doc(id_or_obj=nil, msg=nil, options = {})
		id_or_obj = last_visited unless id_or_obj
		flash[:notice] = msg if msg
    options[:method] = :redirect_to
#logger.info("====> redirect_to_doc(#{id_or_obj}, '#{msg}', #{options.inspect}) calling render_doc(#{id_or_obj}, #{options.inspect})")
		render_doc(id_or_obj, options)
	end

  def render_sidebar(doc_id)
    return SidebarTree.render(doc_id, session, params)
  end

public

  #
  # NOTE: here we do a temporary hack to fix the missing document exception
  #       (cf. [ticket:233 #233]. We just test that the document actually
  #       exists, even though we will eventually duplicate the select twice.
  #       This will be totally fixed with [ticket:159 #159], [ticket:222 #222]
  #       and [ticket:234 #234].
  #
	def show
    logger.silence do
      begin
        doc = Document.find(params[:id])
        safe_doc = doc
      rescue ActiveRecord::RecordNotFound => msg
        flash[:notice] = msg
        safe_doc = get_root
        params.delete(:id)
      end
      @root = render_sidebar(safe_doc.id)
      render_doc(safe_doc, params)
    end
	end

	def front
		params[:id] = get_root
    show
	end
	#
	# date functions
	#

	def visualize_date
		render(:layout => false)
	end

	#
	# reorder children functions
	#
protected

	def reorder_children(doc, so = doc.raw_children_ordering)
		logger.info("====> doc_controller.reorder_children(#{params.inspect}) called")
		doc.reorder_children(so)
	end

public

	def reorder_siblings_and_render
		doc = Document.find(params[:id])
		reorder_children(doc, params[:doc][:sort_order])
		options = {}
		redirect_to_doc(doc, nil, params)
	end

	#
	# search methods
	#
	#-----------------------------------------------------------------------
	# search through the index, get the ActiveRecord's that match and
	# return those to the caller
	#-----------------------------------------------------------------------
	#
	def search
    unless session_user
      redirect_to(:controller => 'account', :action => 'login')
      return
    end
		if params['search']['refine'] == "yes"
			st = session['search_terms'] += (' ' + params['search']['terms'])
		else
			st = session['search_terms'] = params['search']['terms']
		end
		sr = session['search_root'] = params['search']['root']
		logger.silence do
			@tree_root = get_root # needed by the live_tree object in the layout
			@doc = Document.find(last_tree_visited) # needed by the layout
			@search_results = do_the_search(st, sr)

			render(:action => 'search_results', :object => @search_results)
		end
	end

    #
    # sidebar tree management functions
    #

		def update_tree
			root = get_root
			render(:partial => 'lt_tree', :object => root, :layout => false)
		end

    def is_item_active?(id)
      return last_visited == id
    end

    def item_active_tag(id)
      return (is_item_active?(id) ? 'active' : 'inactive') + 'docitem'
    end

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

	#
	# pagination methods
	#
	PER_PAGE_DEFAULT = 30

	def per_page
		session[:per_page] ||= PER_PAGE_DEFAULT
		return session[:per_page]
	end

	def set_pagination
		n = params['doc']['per_page'].to_i
    reset_page_number unless session[:per_page] == n
		session[:per_page] = n if n > 0
		redirect_to_doc(params[:id])
	end

  #
  # authority record form display methods
  #

  def render_ar_form
    doc = Document.find(params[:id])
    ar_form = doc.authority_record_collection[(params[:number].to_i)-1]
    render(:partial => ar_form.class.arclass.inline_form, :object => ar_form)
  end
  
private

  def find_authority_record_collection(pars)
    ar_form_number = (pars[:doc][:ar_form_number]).to_i - 1
    id = pars[:id]
    doc = Document.find(id)
    ar_coll = doc.authority_record_collection[ar_form_number]
    return ar_coll
  end

  def render_authority_record(ar)
    render(:partial => 'ar_show_inner', :object => ar)
  end

public

  def add_authority_record
    ar_coll = find_authority_record_collection(params)
    armeth = ar_coll.class.arclass.create_method
    attrs = params[ar_coll.class.field].dup
    shortcut = ar_coll.class.arclass.autocomplete_parse(attrs[:name])
    attrs[:id] = shortcut[:id] if shortcut[:id]
    attrs.update(params['date']) if params['date']
    ar = ar_coll.doc.send(armeth, session_user, attrs)
    ar_coll.doc.reload 
    render_authority_record(ar_coll)
  end

  def cancel_add_authority_record
    ar_coll = find_authority_record_collection(params)
    render_authority_record(ar_coll)
  end

  def detach_authority_record
    doc = Document.find(params[:id])
    ar = AuthorityRecord.find(params[:ar_record_id])
    doc.detach_authority_record(ar)
    ar_form = doc.authority_record_collection[params[:ar_form_number].to_i - 1]
    render_authority_record(ar_form) 
  end

  #
  # autocomplete ar feature
  #

  include AutoCompleteHelper

public

  def auto_complete_for_person_name_name
    search = params[:person_name][:name]
    auto_completer(search, 'name', PersonName, 'share/autocomplete')
  end

  def auto_complete_for_person_name_first_name
    search = params[:person_name][:first_name]
    auto_completer(search, 'first_name', PersonName, 'ar/pn/autocomplete_first_name')
  end

  def auto_complete_for_collective_name_name
    search = params[:collective_name][:name]
    auto_completer(search, 'name', CollectiveName, 'share/autocomplete')
  end

  def auto_complete_for_site_name_name
    search = params[:site_name][:name]
    auto_completer(search, 'name', SiteName, 'share/autocomplete')
  end

  def auto_complete_for_score_title_name
    search = params[:score_title][:name]
    auto_completer(search, 'name', ScoreTitle, 'share/autocomplete')
  end

  #
  # date management
  #

protected

  def visualized_date(dt, intv, nd)
    displayed_intv = intv == 's.d.' ? intv : intv.to_display
    return 'doc_data_visualizzata', [dt, displayed_intv, nd].conditional_join(', ') 
  end

  def change_date_values_via_rjs(tag, intv, data_topica, nota_data)
    transl = { 'dal' => 'from', 'al' => 'to' }
    @date_id = 'doc_data_' + tag + '_format'
    @date_value = intv.send(transl[tag] + '_format')
    @intv_id = 'doc_full_date_format'
    @intv_value = intv.intv_format
    (@vizdate_id, @vizdate_value) = visualized_date(data_topica, intv, nota_data)
    @dfips_id = 'doc_data_dal_input_parameters'
    @dfips_value = intv.dfips
    @dtips_id = 'doc_data_al_input_parameters'
    @dtips_value = intv.dtips
    render(:template => 'share/change_date_values')
  end

  def all_params_conditioning(from, to, dfips, dtips, intv_f, from_f, to_f)
    return ExtDate::Interval.new(params['from'], params['to'], dfips, dtips, intv_f, from_f, to_f)
  end

  def date_params_conditioning
    from_f = ExtDate::Base.default_date_format_from_hash(params['from'])
    dfips  = ExtDate::Base.date_hash_to_ip_string(params['from'])
    to_f   = ExtDate::Base.default_date_format_from_hash(params['to'])
    dtips  = ExtDate::Base.date_hash_to_ip_string(params['to'])
    intv_f = ExtDate::Interval.default_intv_format(from_f, to_f)
    return all_params_conditioning(params['from'], params['to'], dfips, dtips, intv_f, from_f, to_f)
  end

  def format_params_conditioning
    return all_params_conditioning(params['from'], params['to'],
            params['data_dal_input_parameters'], params['data_al_input_parameters'],
            params['intv_format'], params['from_format'], params['to_format'])
  end

  def single_date_changed(tag, intv, dt, nd)
    change_date_values_via_rjs(tag, intv, dt, nd)
  end

public

  def from_date_changed
    intv = date_params_conditioning
    single_date_changed('dal', intv, params[:data_topica], params[:nota_data])
  end

  def to_date_changed
    intv = date_params_conditioning
    single_date_changed('al', intv, params[:data_topica], params[:nota_data])
  end

  def date_format_changed
    intv = format_params_conditioning
    (@vizdate_id, @vizdate_value) = visualized_date(params[:data_topica], intv, params[:nota_data])
    render(:template => 'share/change_date_formats')
  end

  def senza_data_toggled
    @enabling_method = params['senza_data'] == 'true' ? 'disable' : 'enable'
		logger.info(">>>>>> senza_data_toggled called(#{@enabling_method}): #{params.inspect}")
    @tag_array = [ 'doc_data_dal_day', 'doc_data_dal_month', 'doc_data_dal_year', 'doc_data_dal_format',
                   'doc_data_al_day', 'doc_data_al_month', 'doc_data_al_year', 'doc_data_al_format',
                   'doc_full_date_format' ]
    intv = params['senza_data'] == 'true' ? 's.d.' : format_params_conditioning
    (@vizdate_id, @vizdate_value) = visualized_date(params[:data_topica], intv, params[:nota_data])
    render(:template => "share/toggle_enabling_dates")
  end

  #
  # renumbering of cordas of children
  #

  def renumber_children_cordas
    offset = params[:start_corda_number]
    relative_sort = params[:corda_number_relative_to_year]
    meth = relative_sort ? :relative_renumber_children_cordas : :renumber_children_cordas
    doc = Document.find(params[:id])

    doc.send(meth, offset.to_i)

    redirect_to_doc(doc.id)
  end

  #
  # Name classes dynamic management
  #

  def add_a_record_name
    klass = params[:class].constantize
    nx = session[params[:unitag]].to_i + 1
    locals = { :subkey => klass.subkey.to_s, :index => nx.to_sss,
               :association => params[:association],
               :unitag => params[:unitag],
               :single => params[:single],
               :creator_id => params[:creator_id],
               :last_modifier_id => params[:last_modifier_id],
    }
    render(:partial => 'share/name_single_template', :object => nil, :locals => locals)
  end
  
end
