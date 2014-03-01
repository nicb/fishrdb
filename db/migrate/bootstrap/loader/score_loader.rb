#
# $Id: score_loader.rb 22 2007-10-15 23:27:36Z nicb $
#
module Loader
	module ScoreLoader

		def self.create_from_yaml_data(tree, attrs)
			dl = DescriptionLevel.find(:first, :conditions => ["level = ?", attrs["description_level"]])
			if !dl
				raise ActiveRecord::RecordNotFound, "Description Record Not Found: key = \"" +
					attrs["name"] + "\", level = \"" + attrs["description_level"].to_s + "\""
			end
			user = User.find(:first, :conditions => ["login = ?", "bootstrap"])
			ct = ContainerType.find(:first, :conditions => ["container_type = ?", ''])
			$stderr.printf("\tCreating score: %s\n", attrs["name"])
			attrs["children_ordering"] ||= 'alpha'
			attrs.delete("oldtable")
			attrs.update({ :description_level => dl, :creator => user,
						:last_modifier => user, :container_type => ct })
			#
			# Score *must* have a parent, otherwise might as well fail
			#
			parent = Document.find(:first, :conditions => ["name = ?", attrs["parent"]])
			if !parent
				p = tree.find { |k, v| v["name"] == attrs["parent"] }
				$stderr.printf("\t\trecursively creating parent document: %s\n", p[1].inspect)
				parent = self.create_from_yaml_data(tree, p[1])
			end
			attrs.update(:parent => parent)
			score = Score.create!(attrs)

			return score
		end

	end
end
