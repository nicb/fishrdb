#
# $Id: description_level_loader.rb 22 2007-10-15 23:27:36Z nicb $
#
module Loader
	module DescriptionLevelLoader

		def self.create_from_yaml_data(tree, attrs)
			id = attrs["id"]
			attrs.delete("id")	# protected attribute
			dl = DescriptionLevel.new(attrs)
			dl.id = id
			dl.save!
		end

	end
end
