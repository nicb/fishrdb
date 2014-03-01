#
# $Id: order.rb 459 2009-10-06 07:20:36Z nicb $
#
# sorting, ordering, etc.
#

module DocumentParts

  module Order

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

		protected
			#
			# sorting functions
			#
		
			ORDER_CONVERSION =
			{
				:logic		=> "ordine logico",
				:timeasc 	=> "ordine cronologico ascendente",
				:timedesc 	=> "ordine cronologico discendente",
				:alpha		=> "ordine alfabetico",
				:location	=> "corda, corda_alpha",
				:author	  => "autore",
			}
		
		public
		
		  def sort_hash
				return ORDER_CONVERSION
			end
		
			#
			# sort functions
			#
		
			def by_logic
				return 'position'
			end
		
		  #
		  # TIME ORDERING IS CURRENTLY KLUDGED: since archivists have consistently
		  # used the 'nota_data' field to insert dates (:() we need to add it into the
		  # ordering keys - but of course it will have to be removed once the keys are
		  # in order
		  #
			def by_timeasc
				return 'data_dal ASC, data_al ASC, nota_data ASC'
			end
		
			def by_timedesc
				return 'data_dal DESC, data_al DESC, nota_data DESC'
			end
		
			def by_alpha
				return 'name, name_prefix'
			end
		
			def by_location
				return 'corda, corda_alpha'
			end
		
			def by_author
				return 'autore_score'
			end

    private

      def common_finder(doc, order)
	      so = send('by_' + order.to_s)
	      return find(:all, :conditions => [ "parent_id = ?", doc.read_attribute('id') ], :order => so)
      end

    public

      def create_sorters
        ORDER_CONVERSION.keys.each do
          |k|
          module_eval("def self.sort_by_#{k.to_s}(doc); return common_finder(doc, :#{k.to_s}); end")
        end
      end

    end

		def	human_order
			return ClassMethods::ORDER_CONVERSION[raw_children_ordering]
		end

    #
    # the issue is that ordering is done through children of a given class.
    # Since folders can contain different types of children, this problem
    # can't be solved without major restrictions (== only one type per
    # childhood). So we decide to order by "the majority" of children.
    # Yes, this is a kludge too (FIXME).
    #
    def find_children_most_prominent_class
      result = parent.class
      class_rate = {}
      children.each do
        |c|
        k = c.class.name
        if class_rate.has_key?(k)
          class_rate[k] += 1
        else
          class_rate[k] = 1
        end
      end
      unless class_rate.blank?
        winner = class_rate.sort { |a, b| b[1] <=> a[1] }[0][0]
        result = winner.constantize
      end
      return result
    end

    def reorder_children(new_order= :logic)
      children_class = find_children_most_prominent_class
	    these_children = children_class.send('sort_by_' + new_order.to_s, self)
	    these_children.each_with_index { |c, n| c.update_attributes!(:position => n + 1) }
	    children.reload
		end
	
		def parent_reorder_children
			parent.reorder_children unless !parent
		end
	
		def sort_order
	    return self.class.by_logic
		end
	
	  alias :children_ordering :sort_order
	  alias :raw_children_ordering :children_ordering
		
	end

end
