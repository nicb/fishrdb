#
# $Id: descendant.rb 343 2009-03-22 22:57:05Z nicb $
#
# descendants methods
#

module DocumentParts

  module Descendant

	protected

    #
    # attr_accessors of ActiveRecord objects do not work as usual Ruby
    # accessors because they are overridden to provide ORM encapsulation.
    # This means that the instance has to be created and written using the
    # Object#instance_variable_set method. Once created, the instance
    # variables will be readable/writable through accessor methods
    # 

    attr_accessor :cached_num_descendants
	
		def _count_descendants_(&block)
      myself = 1
			yield(myself)
			children(true).each { |c| c._count_descendants_(&block) }
		end

    def _with_descendants_(results)
        results << self
        children(true).each { |c| c._with_descendants_(results) }
        return results
    end

public

    def with_descendants
        result = []
        return _with_descendants_(result)
    end
	
		def count_descendants
			result = 0
			_count_descendants_ { |n| result += n }
      return result
		end
	
		def reset_num_descendants_cache
      instance_variable_set('@cached_num_descendants', nil)
		end
	
		def num_descendants
			instance_variable_set('@cached_num_descendants', count_descendants - 1) unless cached_num_descendants
			return cached_num_descendants
		end
	
		def count_children_in_records
			n = num_descendants
			return n > 1 ? "#{n+1} records" : "un record"
		end

  end

end
