#
# $Id: cneq_controller.rb 214 2008-05-11 21:47:15Z nicb $
#
class CneqController < ApplicationController

  layout   'ar'

  def show
    @cneq = CnEquivalent.find_by_id(params[:id])
    render(:action => 'show', :id => @cneq.read_attribute('id'))
  end

  def show_set
    @set = CnEquivalent.find(:all, :order => 'name')
    render(:action => 'show_set')
  end

  #
  # edit functions
  #

  def edit
    @cneq = CnEquivalent.find(params[:id])
    render(:partial => 'edit', :object => @cneq)
  end

  def edit_from_form
    if params['commit'] == 'modifica'
      cneq = CnEquivalent.find_by_id(params[:id])
      attrs = params['cn_equivalent'].dup
      attrs[:last_modifier] = session_user
      cneq.update_attributes!(attrs)
    end

    redirect_to(:action => 'show', :id => params[:id])
  end

  #
  # delete methods
  #

  def delete
    cneq = CnEquivalent.find(params[:id])
    cneq.destroy
    redirect_to(:action => 'show_set')
  end

  #
  # CN management
  #

  def detach_collective_name
    cneq = CnEquivalent.find(params[:cneq_id]) 
    cn = CollectiveName.find(params[:id])
    cneq.remove_collective_name(cn, session_user)
    render(:partial => 'cn_list', :collection => cneq.collective_names)
  end

end
