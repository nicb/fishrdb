#
# $Id: public_children.rb 392 2009-05-04 04:09:11Z nicb $
#

module DocumentParts

  module PublicChildren

	public
	
	  def public_children
	    return children(true).find_all_by_public_visibility(true)
	  end
	
  end

end
