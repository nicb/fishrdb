#
# $Id: parenting.rb 628 2012-12-18 11:36:39Z nicb $
#
# list interface and parenting methods
#

module DocumentParts

  module Parenting

	public
	
	  def insert_me(pos=1)
	    p = ((pos && !pos.blank? && pos.to_i > 0) ? pos : 1).to_i
			insert_at(p)
		end
	
	  def parent_me(parent, pos=1)
	    parent.children << self
	    parent.children.reload
	    res = insert_me(pos)
	    parent.children.reload
			res
	  end

  private

    #
    # the issue with reparenting is that if the parent is the same,
    # when  we remove a child from the top we end up in the wrong position
    #
    def calculate_position(new_parent, pos)
      my_pos = position.to_i
      new_pos = pos.to_i
      return (new_parent == parent && my_pos < new_pos) ? new_pos-1 : new_pos
    end

  public
		
		def reparent_me(new_parent, pos=1)
      target_pos = calculate_position(new_parent, pos)
	    parent.children[self.position-1] = nil
			remove_from_list
	    parent.children.compact
			parent.children.reload
	    parent_me(new_parent, target_pos)
		end
	
	  def no_children?
	    return self.children(true).empty?
	  end

  end

end
