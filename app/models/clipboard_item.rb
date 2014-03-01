#
# $Id: clipboard_item.rb 362 2009-04-12 16:34:55Z nicb $
#
class ClipboardItem < ActiveRecord::Base
  belongs_to        :sidebar_tree
  belongs_to        :document
  set_primary_key   :document_id

  validates_presence_of   :sidebar_tree_id
  validates_presence_of   :document_id
  #
  # a document may not by copied by multiple users, because they might end up
  # doing multiple pastings. So we make sure the clipboard is unique
  #
  validates_uniqueness_of :document_id
end
