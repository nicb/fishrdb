#
# $Id: class_methods.rb 362 2009-04-12 16:34:55Z nicb $
#

module SidebarTreeItemParts

	def self.included(base)
	  base.extend ClassMethods
	end

  module ClassMethods

	    def clear_clipboard(st)
	      cstis = find(:all, :conditions => ["sidebar_tree_id = ? and copied_to_clipboard = 'yes'",
	                   st.id ])
	      cstis.each do
	        |sti|
	        sti.remove_from_clipboard
	      end
	    end
	
	    def find_item(st, d_id)
	      return find(:first, :conditions => ["sidebar_tree_id = ? and document_id = ?",
	                    st.id, d_id ])
	    end
	
  end

end
