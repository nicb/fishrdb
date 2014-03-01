#
# $Id: group_selector_helper.rb 1 2007-09-25 18:13:27Z nicb $
#

module GroupSelectorHelper

	def GroupSelectorHelper.truncate(string, limit)
		result = string

		if (string.length-3) > limit
			result = string.slice(0..limit-3) + "..."
		end
	
		return result
	end

	class RecordTarget
		attr_reader	:id, :name
		
		def initialize(id, name)
			@id = id
			@name = GroupSelectorHelper.truncate(name, 65)
		end
	end

	class RecordGroup
		attr_reader :id, :type_name, :options

		def initialize(id, name)
			@id = id
			@type_name = GroupSelectorHelper.truncate(name, 65)
			@options = []
		end

		def <<(rt)
			@options << rt
		end
	end

	class SelectorOptions

		attr_reader :default_selector, :all_options

		def find_root_obj(here_object)

			result = here_object

 			if here_object.parent && here_object.parent.class == @klass
				result = find_root_obj(here_object.parent)
			end
			
			return result
		end

		def build_tree(this_obj, parent_group)
			if !this_obj.children.empty?
				rg = RecordGroup.new(this_obj.id, this_obj.name)
				@all_options << rg

				this_obj.children.each { |roc| build_tree(roc, rg) }
			elsif parent_group
				rt = RecordTarget.new(this_obj.id, this_obj.name)
				parent_group << rt
			end
		end

		def build_selector_options
			build_tree(@root, nil)
		end

		def initialize(root, default_selector)
			@default_selector = default_selector
			@klass = @default_selector.class
			@root = root
			@all_options = []
			build_selector_options
		end

	end

	#
	# here's how this is supposed to be used (inside .rhtml views of course):
	#
	#
    # <label for="order_shipping_option">Shipping: </label>
	#	<select name="whatever[whatever_option]" id="order_shipping_option">
	#    <%= option_groups_from_collection_for_select(GroupSelectorHelper.selector_options(start_point),
	#	                                            :options, :type_name,	# <- groups
	#												:id, :name,				# <- items
	#												start_point) %>
	# </select>

	def GroupSelectorHelper.selector_options(root, here)
		so = SelectorOptions.new(root, here)
		return so.all_options
	end

end
