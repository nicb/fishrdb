#
# $Id: series_loader.rb 94 2007-12-04 10:05:55Z nicb $
#
module Loader
	module SeriesLoader

		def self.create_from_yaml_data(tree, attrs)
			dl = DescriptionLevel.find(:first, :conditions => ["level = ?", attrs["description_level"]])
			if !dl
				raise ActiveRecord::RecordNotFound, "Description Record Not Found: key = \"" +
					attrs["name"] + "\", level = \"" + attrs["description_level"].to_s + "\""
			end
			user = User.find(:first, :conditions => ["login = ?", "bootstrap"])
			ct = ContainerType.find(:first, :conditions => ["container_type = ?", ''])
			$stderr.printf("\tCreating series: %s with attrs: %s\n", attrs["name"], attrs.inspect)
			attrs["children_ordering"] ||= 'logic'
			attrs.delete("oldtable")
			attrs.update({ :description_level => dl, :creator => user,
						:last_modifier => user, :container_type => ct })
			#
			# Series *must* have a parent, otherwise might as well fail
			#
			parent = Document.find(:first, :conditions => ["name = ?", attrs["parent"]])
			if !parent
				p = tree.find { |k, v| v["name"] == attrs["parent"] }
				$stderr.printf("\t\trecursively creating parent document: %s\n", p[1].inspect)
				parent = self.create_from_yaml_data(tree, p[1])
			end
			attrs.update(:parent => parent)
			series = Series.create!(attrs)

			return series
		end

	end
end
