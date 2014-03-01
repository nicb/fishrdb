#
# $Id: user_loader.rb 22 2007-10-15 23:27:36Z nicb $
#
module Loader
	module UserLoader

		def self.create_from_yaml_data(tree, attrs)
			attrs["password_confirmation"] = attrs["password"]
			attrs.delete("id") # protected from mass assignement
			User.create!(attrs)
		end

	end
end
