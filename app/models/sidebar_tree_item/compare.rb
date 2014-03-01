#
# $Id: compare.rb 324 2009-03-06 04:26:22Z nicb $
#

module SidebarTreeItemParts

  module Compare

	private
	
	  def compare(truth_value, other)
	    return  truth_value && (self.sidebar_tree === other.sidebar_tree)
	  end
	
	public
	
	  def ==(other)
	    return compare(super(other), other)
	  end
	
	  def ===(other)
	    return compare(super(other), other)
	  end

  end

end
