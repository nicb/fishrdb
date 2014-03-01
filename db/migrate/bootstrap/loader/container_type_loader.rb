#
# $Id: container_type_loader.rb 22 2007-10-15 23:27:36Z nicb $
#
module Loader
	module ContainerTypeLoader

		def self.create_from_yaml_data(tree, attrs)
			id = attrs["id"]
			attrs.delete("id")	# protected attribute
			ct = ContainerType.new(attrs)
			ct.id = id
			ct.save!
		end

	end
end
