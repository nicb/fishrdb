#
# $Id: children.rb 392 2009-05-04 04:09:11Z nicb $
#

module SidebarTreeItemParts

  module Children

      attr_accessor :children_cache

    private

      def children_cache_set(val)
        instance_variable_set('@children_cache', val)
      end

		protected
		
		  def find_children_in_db(additional_conditions = '')
		    return self.class.find_by_sql(["select sidebar_tree_items.* from sidebar_tree_items left join documents on sidebar_tree_items.document_id = documents.id where documents.parent_id = ? and sidebar_tree_id = ? #{additional_conditions} order by documents.position", document.id, sidebar_tree_id])
		  end
		
		  def find_children(not_cached = false, additional_conditions = '')
        if not_cached || children_cache.blank?
		      children_cache_set(find_children_in_db(additional_conditions))
		    end
		    return children_cache
		  end

      def find_public_children
        return find_children(true, ' and documents.public_visibility = 1 ')
      end
		
		  def create_children(selected_document = nil)
        cc = []
		    children_documents = document.children(true)
		    if children_documents.size > 0
		      destroy_children if children_cache
          cc = children_documents.map do
			      |cd|
			      sidebar_tree.sidebar_tree_items.create(:document => cd)
			    end
		    end
        sidebar_tree.select_document(selected_document) if (selected_document && !selected_document.frozen?)
        children_cache_set(cc)
		  end
		
		  def destroy_children
        saved_selected = nil
		    children.each do
		      |c|
		      c.destroy_children
          saved_selected = c.document if c.sidebar_tree.selected_item == c
		      c.destroy
		    end
        children_cache_set(nil)
        return saved_selected
		  end
		
		public
		
		  def children(not_cached = false)
		    return open? ? find_children(not_cached) : []
		  end

		  def has_children?
		    return find_children.size > 0 ? true : false
		  end
		
		  def potentially_has_children?
		    return document.children_size > 0 ? true : false
		  end
		
      def public_children
        return open? ? find_public_children : []
      end
		
      def has_public_children?
        return find_public_children.size > 0 ? true : false
      end
		
		  def potentially_has_public_children?
		    return document.public_children.size > 0 ? true : false
		  end
		  #
		  # rebuild children tree
		  #
		
		  def rebuild_children_tree
		    old_children = find_children
		    statuses = {}
		    old_children.each { |oc| statuses[oc.document_id] = oc.status }
		    selected_document = destroy_children
		    create_children(selected_document)
		    new_children = find_children
		    new_children.each do
		      |nc|
		      s = statuses.has_key?(nc.document_id) ? statuses[nc.document_id] : :closed
		      nc.open_without_selecting_me if s == :open
		    end
		  end

      #
      # expose/unexpose methods
      #

      def expose_children
        unless instance_variables.include?('@children_cache')
          create_children 
        end
        return children_cache
      end

      def unexpose_children
        #
        # don't do anything for now
        #
      end

	end

end
