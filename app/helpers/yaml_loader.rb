#
# $Id: yaml_loader.rb 15 2007-10-11 05:42:32Z nicb $
#

module YamlLoader

	def YamlLoader.do_create_from_yaml_file(klass, filename)
		file = File.dirname(__FILE__) + "/../../test/fixtures/" + filename
		tree = YAML.load(File.open(file, "r"))
		raise "YAML file '#{filename}' parse error" unless tree
		tree.each_value do
			|v|
			done = klass.find(:first, :conditions => ["name = ?", v["name"]])
			klass.create_from_yaml_data(tree, v) unless done
		end
	end
end
