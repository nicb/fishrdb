#
# $Id: fisold_reference_db.rb 173 2008-02-22 11:52:00Z nicb $
#

class FisoldReferenceDb < ActiveRecord::Base
  has_many  :documents
end
