#
# $Id: sidebar_tree.rb 615 2012-06-07 21:27:49Z nicb $
#
class SidebarTree < ActiveRecord::Base

  include DocHelper

  attr_reader :root

  validates_presence_of   :session_id

  has_many    :sidebar_tree_items, :dependent => :destroy
  has_many    :documents, :through => :sidebar_tree_items
  belongs_to  :selected_item, :class_name => 'SidebarTreeItem'

  has_many    :clipboard_items, :dependent => :destroy
  has_many    :clipped_documents, :class_name => 'Document', :through => :clipboard_items, :source => :document

public

  def recover_root
    root_doc = Document.fishrdb_root
    raise "Document.root returned a false value - there's something seriously wrong with the system" unless root_doc
    @root = find_sidebar_item(root_doc.read_attribute(:id))
    unless @root
      @root = sidebar_tree_items.create(:document => root_doc)
    end
    @root.open_without_selecting_me # all items are closed by default, just the root is open in the beginning
    return @root
  end

  def find_sidebar_item(doc_id)
    return sidebar_tree_items.find_or_create_by_document_id(doc_id)
  end

  class <<self

	  def create(parms = nil)
	    sbt = super(parms)
      raise "SidebarTree cannot be created because: #{sbt.errors.full_messages.join(', ')}" unless sbt.valid?
	    sbt.recover_root
	    return sbt
	  end
	
	  def retrieve(session)
      raise "No session!" unless session
			#
			# FIXME: I still don't understand why sometimes the session.session_id
			# is set while in other instances the attribute ['session_id'] is set.
			# Until I don't understand what is going on, I shall use this poor hack
			# to make sure I have got the session_id allright
			#
			sid = session.session_id.empty? ? session['session_id'] : session.session_id
	    sbt = find_by_session_id(sid)
	    if sbt
	      sbt.recover_root
	    else
	      sbt = create(:session_id => sid)
	    end
	    return sbt
	  end

	  #
	  # if params[:open_tree] == 'false' and sbi.open?  --> open_tree
	  # if params[:open_tree] == 'false' and sbi.close? --> DO NOT open_tree
	  # all other cases                                 --> open_tree
	  #
    def render(doc_id, session, parms)
	    sb = retrieve(session)
	    open_flag = true
	    if (parms.has_key?(:open_tree) && parms[:open_tree] == 'false')
	      sbi = sb.sidebar_tree_items.find_by_document_id(doc_id)
	      open_flag = false if (sbi && sbi.closed?)
	    end
	    sb.open_tree_up_to_document(doc_id) if open_flag
	    return sb.root
    end

	  def clipboard_empty?(session)
	    sb = retrieve(session)
	    return sb.clipboard_items(true).blank?
	  end

	  #
	  # open/close -> doc->show items actions
	  #
	
	private
	
	  def unprotected_action(sess, pars, &block)
	    sb = SidebarTree.retrieve(sess)
	    sbi = sb.sidebar_tree_items.find_by_document_id(pars[:id])
	    raise(ActiveRecord::RecordNotFound, "Sidebar Tree Item not found for document n.#{pars[:id].to_s}") unless sbi
	    yield(sbi)
	    sb.reload
      args = { :id => pars[:id] }
	    args.update(:open_tree => pars[:open_tree]) if pars.has_key?(:open_tree)
      return args
	  end
	
	  def action(sess, pars, &block)
      begin
        result = unprotected_action(sess, pars, &block)
      rescue ActiveRecord::RecordNotFound => msg
        result = { :message => msg }
      end
      return result
    end

	public
	
	  def toggle(sess, pars)
	    return action(sess, pars) { |sbi| sbi.toggle }
	  end
	
	  def open(sess, pars)
	    return action(sess, pars) { |sbi| sbi.open }
	  end

  end

  def clear_clipboard
    clipboard_items(true).each do
      |ci|
      sbti = find_sidebar_item(ci.document_id)
      sbti.remove_from_clipboard
    end
  end

  def open_tree_up_to_document(doc_id)
    doc = Document.find(doc_id)
    doc.ancestors.reverse.each do
      |d|
      sbti = find_sidebar_item(d.id)
      sbti.open_without_selecting_me
    end
    final = find_sidebar_item(doc.id)
    final.open
    return final
  end

  def select_sidebar_item(sbti)
    update_attributes!(:selected_item => sbti)
  end

  def select_document(doc)
    sbti = find_sidebar_item(doc.id)
    select_sidebar_item(sbti)
  end

end
