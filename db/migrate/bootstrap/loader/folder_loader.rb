#
# $Id: folder_loader.rb 30 2007-10-24 16:24:52Z nicb $
#
module Loader
	module FolderLoader

		def self.create_from_yaml_data(tree, attrs)
			dl = DescriptionLevel.find(:first, :conditions => ["level = ?", attrs["description_level"]])
			if !dl
				raise ActiveRecord::RecordNotFound, "Description Record Not Found: key = \"" +
					attrs["name"] + "\", level = \"" + attrs["description_level"].to_s + "\""
			end
			user = User.find(:first, :conditions => ["login = ?", "bootstrap"])
			ct_id = ContainerType.find(:first, :conditions => ["container_type = ?", '']).id
			$stderr.printf("\tCreating folder: %s\n", attrs["name"])
			attrs["children_ordering"] ||= 'logic'
			attrs.update(:description_level => dl, :creator => user,
						 :last_modifier => user, :container_type_id => ct_id)
			#
			# If no parent, then it must be a root folder. We treat a root folder as a
			# folder with a nil parent
			#
			parent = attrs.has_key?("parent") ? tree[attrs["parent"]] : nil
			if parent
				parent_record = Document.find(:first, :conditions => ["name = ?", parent["name"]])
				if !parent_record
					$stderr.printf("\t\trecursively creating parent document: %s\n", parent["name"])
					parent_record = self.create_from_yaml_data(tree, parent)
				end
				attrs.update(:parent => parent_record)
			end
			folder = Folder.create!(attrs)
			return folder
		end

	end
end
