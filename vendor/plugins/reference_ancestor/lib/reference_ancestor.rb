# ReferenceAncestor
#
# $Id: reference_ancestor.rb 536 2010-08-22 02:32:10Z nicb $
#

require 'reference_ancestor/active_record_extensions'

class ActiveRecord::Base

  extend ReferenceAncestor::ActiveRecordExtensions::ClassMethods

end
