#
# $Id: paginate.rb 565 2010-11-28 19:53:45Z nicb $
#
# this adds the behavior of will_paginate to the children method
#

module DocumentParts

  module Paginate

		def self.included(base)
		  base.extend ClassMethods
		end

		def paginated_children(page=1, per_page=10)
			return Document.paginate(:all, :conditions => ["parent_id = ?", self.id],
					:order => self.sort_order, :page => page, :per_page => per_page)
		end

    module ClassMethods

		  def pages?(num, items_per_page)
        result = num
        if items_per_page && items_per_page.to_i > 0
		      result = (num.to_f/items_per_page.to_f).ceil
		      result = result < 1 ? 1 : result
        end
		    return result
		  end

    end # end of ClassMethods

	  def num_pages(items_per_page)
	    return self.class.pages?(children(true).size, items_per_page)
	  end

	  def my_page(items_per_page)
	    return self.class.pages?(position, items_per_page)
	  end

	  def args_for_url_for_with_paging(action, page)
	    args = { :action => action, :id => self.id }
	    args[:page] = page if page
	    return args
	  end
	
	  def breadcrumbs_with_paging(items_per_page, &block)
	    bc = ancestors.reverse
	    unless bc.blank?
	      last = bc.size-1
		    bc.each_with_index do
		      |d, i|
	        unless i == last
			      next_d = bc[i+1]
		        next_page = next_d.my_page(items_per_page)
	        else
		        next_page = my_page(items_per_page)
	        end
	        next_page = next_page > 1 ? next_page : nil
	        yield(d, next_page)
		    end
	    end
	  end

  end

end
