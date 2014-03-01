#
# $Id: ar_controller.rb 472 2009-10-19 15:11:48Z nicb $
#

#require 'authority_record'
#require 'document/authority_record_collection'
require 'date_extensions'
require 'errors_intl_extensions'

class ArController < ApplicationController

  def index
  end

private

  def show_set(set, partial = 'ar_record', action = :render)
    @set = set
    @partial = partial
    send(action, :action => 'show_set')
  end

  #
  # we must make sure that we get only the parent class object,
  # no variant subclasses
  #
  def ar_find(classname, order = 'name')
    return classname.find(:all, :conditions => ['type = ?', classname.to_s],
                          :order => order)
  end

public

  def show_person_names
    show_set(ar_find(PersonName, 'name, first_name'))
  end

  def show_collective_names
    show_set(ar_find(CollectiveName))
  end

  def show_site_names
    show_set(ar_find(SiteName))
  end

  def show_score_titles
    show_set(ar_find(ScoreTitle))
  end

public

  def show
    @ar = AuthorityRecord.find(params[:id])
    render(:action => 'show')
  end

  #
  # cancel action
  #

  def cancel_action
    ar = AuthorityRecord.find(params[:id])
    render(:partial => 'show', :object => ar, :layout => false)
  end

  #
  # delete functions
  #

  def delete
    ar = AuthorityRecord.find(params[:id])
    ar.destroy
    if ar.variant?
      redirect_to(:action => 'show', :id => ar.accepted_form.id)
    else
      redirect_to(:action => "show_#{ar.class.name.underscore.pluralize}")
    end
  end

protected

  def commit_reply(ok_tag, &block)
    ar = AuthorityRecord.find(:first, :conditions => ['id = ?', params['id']])
    unless ar
      arclass = params['class_name'].constantize
      ar = arclass.new
    end
    #
    # this is needed to accomodate CN parameters
    #
    params['authority_record'].update(params['date']) if params['date']

    begin
      yield(ar, params) if params['commit'] == ok_tag
    rescue ActiveRecord::RecordInvalid
      headmsg = ar.errors.size > 1 ? 'Ci sono degli errori' : "C'è un errore"
      flash[:notice] = "#{headmsg} nell'immissione dei dati:"
      flash[:errors] = ar.errors
      params.delete(:commit)
      redirect_to(:action => :create, :class_name => ar.class.name, :authority_record => params[:authority_record])
    else
      if ar.id
        redirect_to(:action => 'show', :id => ar.accepted_form.id)
      else
        show_set_method = 'show_' + ar.accepted_form.class.name.underscore.pluralize
        send(show_set_method)
      end
    end
  end

public
  #
  # edit functions
  #

  def edit
    @ar = AuthorityRecord.find(params[:id])
    edit = @ar.class.master_class.edit_action
    render(:partial => edit, :object => @ar)
  end

  def edit_from_form(field = 'authority_record')
    commit_reply('salva') do
      |ar, pars|
      attrs = pars[field].dup
      attrs[:last_modifier_id] = session_user.id
      # this might get called from create, so it might need a creator too
      attrs[:creator_id] = session_user.id unless ar.creator
      ar.class.adjust_dates(attrs)
      ar.update_attributes!(attrs)
    end
  end

private

  def get_person_name(name, first_name)
    pn = PersonName.find(:first, :conditions => ['name = ? and first_name = ?', name, first_name])
    unless pn
      user = session_user
      pn = PersonName.create(:name => name, :first_name => first_name,
                             :creator_id => user.id, :last_modifier_id => user.id)
    end
    return pn
  end

public

  def score_title_edit_from_form
    ScoreTitle.extended_fields.each do
      |sf|
      results = PersonName.autocomplete_parse(params[:score_title][sf.keys[0]])
      unless results[:name].blank?
        pn = PersonName.find(results[:id]) if results[:id]
        unless pn
          name = results[:name]
          first_name = params[:score_title][sf.keys[0].to_s + '_first_name']
          pn = get_person_name(name, first_name)
        end
        params[:score_title].update(sf.keys[0] => pn)
      else
        params[:score_title].delete(sf.keys[0])
      end
      params[:score_title].delete(sf.keys[0].to_s + '_first_name')
    end
    edit_from_form('score_title')
  end

  #
  # create functions
  #

  def create
    arclass = params[:class_name].constantize
    attrs = params.has_key?(:authority_record) ? params[:authority_record] : {}
    @ar = arclass.new(attrs)
    render(:action => 'create')
  end

  #
  # variant form functions
  #
  
  def variant_form
    ar = AuthorityRecord.find(params[:id])
    render(:partial => ar.class.variant_action, :object => ar)
  end

  def add_variant_form
    commit_reply('aggiungi') do
      |ar, pars|
	    attrs = pars['authority_record'].dup
	    attrs.delete('id')
	    attrs['creator_id'] = attrs['last_modifier_id'] = session_user.id
	    eqmeth = "#{ar.class.name.underscore}_variants"
	    arv = ar.send(eqmeth).create(attrs)
      raise "Failed to create variant #{attrs.inspect}" unless arv
    end
  end

  #
  # equivalent form functions
  #

  def add_equivalent_form
    attrs = params['authority_record']
    unless attrs['cn_equivalent'].blank?
      u = session_user
      cn = CollectiveName.find_by_id(params[:id])
      cneq = CnEquivalent.find_by_name(attrs['cn_equivalent'])
      unless cneq
        cneq = CnEquivalent.create(:name => attrs['cn_equivalent'], 
                                  :creator_id => u.id, :last_modifier_id => u.id)
      end
      cneq.add_collective_name(cn, u)
      redirect_to(:action => 'show', :id => cn.id)
    else
      redirect_to(:action => 'show', :id => params[:id])
    end
  end

  #
  # interactive update of first_name in person_names
  #
private

  def do_update_person_name_first_name(input_string, div, rjs)
    results = PersonName.autocomplete_parse(input_string)
    pn = PersonName.find(results[:id]) if results[:id]
    pn = PersonName.find_by_name(results[:name]) unless pn
    @first_name = ''
    @first_name = pn.first_name unless pn.blank?
    @div = div

    render :template => rjs
  end

public

  def update_person_name_first_name(div= 'person_name_first_name', rjs = 'ar/pn/update_person_name_first_name')
    input_string = ''
    params.each do
      |k, v|
      if !v
        input_string = k
        break
      end
    end
    do_update_person_name_first_name(input_string, div, rjs)
  end
  #
  # ScoreTitle autocomplete methods
  #

  include AutoCompleteHelper

private

  def st_edit_autocomplete(sym, sfield = 'name')
    search = params[:score_title][sym]
    auto_completer(search, sfield, PersonName, 'share/autocomplete')
  end

public

  def auto_complete_for_score_title_author
    st_edit_autocomplete(:author)
  end

  def auto_complete_for_score_title_author_first_name
    st_edit_autocomplete(:author_first_name, 'first_name')
  end

  def update_score_title_author_first_name
    update_person_name_first_name(div= 'score_title_author_first_name')
  end

  def auto_complete_for_score_title_transcriber
    st_edit_autocomplete(:transcriber)
  end

  def auto_complete_for_score_title_transcriber_first_name
    st_edit_autocomplete(:transcriber_first_name, 'first_name')
  end

  def update_score_title_transcriber_first_name
    update_person_name_first_name(div= 'score_title_transcriber_first_name')
  end

  def auto_complete_for_score_title_lyricist
    st_edit_autocomplete(:lyricist)
  end

  def auto_complete_for_score_title_lyricist_first_name
    st_edit_autocomplete(:lyricist_first_name, 'first_name')
  end

  def update_score_title_lyricist_first_name
    update_person_name_first_name(div= 'score_title_lyricist_first_name')
  end

  #
  # date management
  #
protected

  def change_date_values_via_rjs(tag, intv)
    transl = { 'start' => 'from', 'end' => 'to' }
    @date_id = 'authority_record_date_' + tag + '_format'
    @date_value = intv.send(transl[tag] + '_format')
    @intv_id = 'authority_record_full_date_format'
    @intv_value = intv.intv_format
    @dfips_id = 'authority_record_date_start_input_parameters'
    @dfips_value = intv.dfips
    @dtips_id = 'authority_record_date_end_input_parameters'
    @dtips_value = intv.dtips
    render(:template => 'ar/pn/change_date_values')
  end

  def all_params_conditioning(from, to, dfips, dtips, intv_f, from_f, to_f)
    return ExtDate::Interval.new(from, to, dfips, dtips, intv_f, from_f, to_f)
  end

  def date_params_conditioning
    from_f = ExtDate::Base.default_date_format_from_hash(params['from'])
    dfips  = ExtDate::Base.date_hash_to_ip_string(params['from'])
    to_f   = ExtDate::Base.default_date_format_from_hash(params['to'])
    dtips  = ExtDate::Base.date_hash_to_ip_string(params['to'])
    intv_f = ExtDate::Interval.default_intv_format(from_f, to_f)
    return all_params_conditioning(params['from'], params['to'], dfips, dtips, intv_f, from_f, to_f)
  end

  def single_date_changed(tag, intv)
    change_date_values_via_rjs(tag, intv)
  end

public

  def from_date_changed
logger.info(">>>> ar::from_date_changed: params = #{params.inspect}")
    intv = date_params_conditioning
    single_date_changed('start', intv)
  end

  def to_date_changed
logger.info(">>>> ar::to_date_changed: params = #{params.inspect}")
    intv = date_params_conditioning
    single_date_changed('end', intv)
  end

end
