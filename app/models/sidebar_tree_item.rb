#
# $Id: sidebar_tree_item.rb 362 2009-04-12 16:34:55Z nicb $
#

class SidebarTreeItem < ActiveRecord::Base

  belongs_to        :sidebar_tree
  belongs_to        :document

  validates_presence_of   :sidebar_tree_id
  validates_presence_of   :document_id
  validates_uniqueness_of :document_id, :scope => :sidebar_tree_id

end

STI_PATH='sidebar_tree_item/'

require_dependency STI_PATH + 'class_methods'
require_dependency STI_PATH + 'status'
require_dependency STI_PATH + 'children'
require_dependency STI_PATH + 'selection'
require_dependency STI_PATH + 'compare'
require_dependency STI_PATH + 'copy'

SidebarTreeItem.class_eval do
  include SidebarTreeItemParts
  include SidebarTreeItemParts::Status
  include SidebarTreeItemParts::Children
  include SidebarTreeItemParts::Selection
  include SidebarTreeItemParts::Compare
  include SidebarTreeItemParts::Copy
end

