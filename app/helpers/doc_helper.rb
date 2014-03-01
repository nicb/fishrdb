#
# $Id: doc_helper.rb 445 2009-09-24 14:19:25Z nicb $
#

module DocHelper

private

	def get_root
		session[:root] ||= Document.fishrdb_root
		return session[:root]
	end

	def remember_tree(tree_id)
  		session[:tree_return_to] = tree_id
	end

	def remember_last(id, tree_id=id)
		logger.info("====> remember_last(#{id}, #{tree_id})")
    session[:return_to] = id
		remember_tree(tree_id)
  end

  def session_record_is_valid?
    return Document.find(:first, :conditions => ["id = ?", session[:return_to]])
  end

protected

	def rescue_redirect(msg=nil)
		#
		# we clear the session data related to the return paths
		# if we find it to be stale
		#
		if session[:return_to]
		  remember_last(nil) unless session_record_is_valid?
		end
logger.info("====> rescue_redirect(#{msg}) called, now calling 'redirect_to_doc(nil, #{msg})'")
		redirect_to_doc(nil, msg)
	end

	def last_visited
		return session[:return_to] || get_root
	end

	def last_tree_visited
		return session[:tree_return_to] || get_root
	end

  def reset_page_number
    session[:last_page] = session[:page] = nil
  end

  def page_number(id)
    result = 1
    doc = Document.find(id)
    if doc.parent
	    doc.parent.children.reload
      result = doc.my_page(per_page)
    end
    return result
  end

end
