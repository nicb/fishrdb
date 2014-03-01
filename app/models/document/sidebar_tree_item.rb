#
# $Id: sidebar_tree_item.rb 454 2009-10-02 20:51:29Z nicb $
#

module DocumentParts

  module SidebarTreeItem

    def sidebar_tree_item(session)
      result = nil
#     sidebar_tree_items.each { |sbi| result = sbi if sbi.sidebar_tree_user_id == for_user.id }
      sb = SidebarTree.find_or_create_by_session_id(session.session_id)
      return sidebar_tree_items.find_by_sidebar_tree_id(sb.id)
    end

  end

end
