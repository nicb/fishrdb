#
# $Id: sidebar_controller.rb 481 2010-04-02 01:43:24Z nicb $
#

require 'sidebar_tree'

class SidebarController < ApplicationController

private

  def do_show(sbt)
    @root = sbt.root
    render(:action => 'show')
  end

public

  def show
    sb = SidebarTree.retrieve(session)
    do_show(sb)
  end

  def toggle
    sb = SidebarTree.retrieve(session)
    sbi = sb.find_sidebar_item(params[:document_id])
    sbi.toggle
    do_show(sb)
  end

  #
  # copy/paste methods
  #
protected

  def redirect_back(sb)
    if sb.selected_item
      doc_id = sb.selected_item.document.id
    else
      doc_id = Document.fishrdb_root.id
    end
    redirect_to( :controller => :doc, :action => :show, :id => doc_id)
  end

  def act_with_selection(&block)
		selected = params["copied_to_clipboard"].map { |k, v| k.to_i unless v == "no" }.compact
		logger.info("===> SidebarController#act_with_selection: doc id: #{params[:id]},  params: #{params.inspect}, selected: #{selected.inspect}")
    yield selected
  end

  def copy_to_clipboard(sb)
    SidebarTreeItem.clear_clipboard(sb) # clean clipboard before (re)-selecting
    act_with_selection do
      |sel|
	    sel.each do
	      |d_id|
	      sti = SidebarTreeItem.find_item(sb, d_id) # this should never return nil
	      sti.copy_to_clipboard
	    end
    end
  end

public

  def copy
    sb = SidebarTree.retrieve(session)
    copy_to_clipboard(sb)
    redirect_back(sb)
  end

  #
  # the 'delete selected' sequence of operation is as follows:
  #
  # user selects items
  # presses 'cancella selezionati' -> delete_confirmation -> popup page
  # presses 'conferma' -> delete_or_cancel -> delete -> redirect_back
  # or
  # presses 'cancel' -> redirect_back
  #

  def delete(sb, selected)
    selected.each do
      |d_id|
      doc = Document.find(d_id.to_i)
      sti = doc.sidebar_tree_item(session).reload
      if sti.selected?
        sb.update_attributes!(:selected_item => doc.parent.sidebar_tree_item(session))
        sb.reload
      end
      doc.delete_from_form if doc
    end
  end

  def delete_or_cancel
    sb = SidebarTree.retrieve(session)
    if button_pressed?('delete')
		  logger.info("===> SidebarController#delete_or_cancel: params: #{params.inspect}")
      delete(sb, params['selection'])
    end
    redirect_back(sb) 
  end

  def delete_confirmation
    sb = SidebarTree.retrieve(session)
    copy_to_clipboard(sb)
		selected = params["copied_to_clipboard"].map { |k, v| k.to_i unless v == "no" }.compact
    @docs = selected.map { |s| Document.find(s) }
    render(:action => :delete_confirmation, :layout => 'popup')
  end

public

  def clear_selection
    sb = SidebarTree.retrieve(session)
    SidebarTreeItem.clear_clipboard(sb)
    redirect_back(sb)
  end

  def manipulate_selection
    if button_pressed?('copy')
      meth = :copy
    elsif button_pressed?('clear_selection')
      meth = :clear_selection
    elsif button_pressed?('delete_confirmation')
      meth = :delete_confirmation
    end
    send(meth)
  end

protected

  def collect_dirty(target, sources)
    result = [ target ]
    sources.each { |d| result << d.parent_id if d.parent_id }
    result.uniq!
    return result
  end

  def clean_tree(sb, dirty_parents)
    dirty_parents.each do
      |d_id|
      sbti = SidebarTreeItem.find_item(sb, d_id)
      sbti.rebuild_children_tree
    end
  end

  def paste_somewhere(where)
    @where = where
    @next_action = @where == 'sopra' ? :paste_sibling : :paste_child
    @here_doc = Document.find(params[:id])
    raise "Trying to paste to non-existent Document n.#{params[:id]}" unless @here_doc
    sb = SidebarTree.retrieve(session)
    #
    # this should be simply ci.document, but there appears to be a problem in
    # loading so that clipboard_items are not always properly loaded with
    # accessors
    #
    @docs = sb.clipboard_items.map { |ci| Document.find(ci.document_id) }
    render(:action => :paste_confirmation, :layout => 'popup')
  end

public
  #
  # the 'paste selected' sequence of operation is as follows:
  #
  # user selects items
  # presses a 'paste sibling above here' button -> paste_sibling_confirmation -> popup_page
  # or
  # presses a 'paste child below here' button -> paste_child_confirmation -> popup_page
  # presses 'conferma' -> paste_or_cancel -> paste -> redirect_back
  # or
  # presses 'cancel' -> redirect_back
  #


  def paste_sibling_above_here
    paste_somewhere('sopra')
  end

  def paste_child_below_here
    paste_somewhere('sotto')
  end

protected

  def paste(sb, target, selection, position)
    clips = selection.map { |id| d = Document.find(id); looping_paste?(target, d) ? nil : d }.compact
    dirty_parents = collect_dirty(target.id, clips)
    clips.reverse.each { |d| d.reparent_me(target, position) }
    clean_tree(sb, dirty_parents)
    sb.clear_clipboard
  end

  def looping_paste?(target, src)
    return target.id == src.id
  end

public

  def paste_sibling(sb, id, selection)
    target = Document.find(id)
    paste(sb, target.parent, selection, target.position)
  end

  def paste_child(sb, id, selection)
    target = Document.find(id)
    paste(sb, target, selection, target.children(true).size)
  end

  def paste_or_cancel
    sb = SidebarTree.retrieve(session)
    if button_pressed?('paste')
		  logger.info("===> SidebarController#paste_or_cancel: params: #{params.inspect}")
      send(params[:next_action], sb, params['id'], params['selection'])
    end
    redirect_back(sb.reload) 
  end

end
