#!/usr/bin/env ruby
# 
# $Id: convertdb.rb 22 2007-10-15 23:27:36Z nicb $
#
# This script uses ActiveRecord and it is used to convert from the old
# database schema to the new one.
#

def populate_table(klass, unique="name")

	name = klass.name.tableize
	filename = "data/yml/" + name + ".yml"
	reqname = "loader/#{klass.name.underscore}_loader"

	require reqname

	module_name = "loader/#{klass.name}" + "Loader"
	module_name = module_name.classify.constantize

	include module_name

	$stderr.printf("\tpopulating table %s\n\t  (\"%s\", '%s', %s)\n", klass, filename, reqname, module_name.to_s)

	tree = YAML.load(File.open(filename, "r"))
	#
	# tree might well be empty because the file is empty
	#
	if tree
		include module_name
	
		tree.each_value do
			|v|
			done = klass.find(:first, :conditions => ["#{unique} = ?", v["#{unique}"]])
			module_name.create_from_yaml_data(tree, v) unless done
		end
	else
		$stderr.printf("\tWARNING: the table \"%s\" appears to be empty: nothing done.\n", filename)
	end

end

def populate(connection)
	ActiveRecord::Base.establish_connection(connection)
	tables = 
	[
		{ :klass => User,				:unique => "login" },
		{ :klass => DescriptionLevel,	:unique => "level" },
		{ :klass => ContainerType,		:unique => "container_type" },
		{ :klass => Folder,				:unique	=> "name"},
		{ :klass => Series,				:unique	=> "name"},
		{ :klass => Score,				:unique	=> "name"},
	]
	tables.each { |t| populate_table(t[:klass], t[:unique]) }
	ActiveRecord::Base.remove_connection
end

def create_trees
	conns = ["development"]#, "test"]#, "production"]

	conns.each do
		|db|
		$stderr.printf("%%%%%% DATABASE: %s %%%%%%%%\n", db)
		ENV["RAILS_ENV"] = db
		require 'convert_environment'
		connection_data = YAML.load(File.open($config_prefix + "database.yml"))
		
		populate(connection_data[db])
	end
end

create_trees
