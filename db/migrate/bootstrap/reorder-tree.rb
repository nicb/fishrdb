#!/usr/bin/env ruby
#
# $Id: reorder-tree.rb 49 2007-11-06 08:42:07Z nicb $
#

require 'convert_environment'

SERIES_ORDER_SPECIALS =
{
	"Corrispondenza" => "alpha",
	"Scritti Filosofici e Poetici" => "alpha",
	"Riviste" => "alpha",
	"Opuscoli" => "alpha",
	"Beni di famiglia" => "timeasc",
	"Documenti contabili-amministrativi" => "timeasc",
	"Rapporti con le banche" => "timeasc",
	"Appunti personali" => "timeasc",
	"Annotazioni sulla musica" => "timeasc",
	"Recensioni musicali e articoli di Giornale" => "timeasc",
	"Eventi musicali" => "timeasc",
	"Programmi" => "timeasc",
	"Manifesti e locandine" => "timeasc",
	"Inviti" => "timeasc",
	"Brochures e Dépliants" => "timeasc",
}

SCORE_ORDER_SPECIALS =
{
	"Partiture Giacinto Scelsi" => "alpha",
	"Partiture altri autori" => "alpha"
}

def do_logic_order(yaml_file)
	tree = YAML.load(File.open("data/yml/" + yaml_file + ".yml"))
	tree.each do
		|k, v|

		if v.has_key?('position')
			name = v['name']
			doc = Document.find_by_name(name)
			if doc
				parent_string = doc.parent ? " within \"#{doc.parent.name}\"" : ""
				$stderr.puts("\tinserting \"#{doc.name}\" at position #{v['position']}#{parent_string}...")
				doc.update_attribute('position', v['position'])
			else
				raise ActiveRecord::RecordNotFound, "record #{name} not found during reordering!"
			end
		end
	end
end

def do_logic_orders
	yaml_files = [ "folders", "series" ]
	yaml_files.each { |f| do_logic_order(f) }
end

def do_reorder
	SERIES_ORDER_SPECIALS.each do
		|k, v|
		pnode = Document.find(:first, :conditions => ["name = ?", k])
		pnode.reorder_children(v)
	end
	SCORE_ORDER_SPECIALS.each do
		|k, v|
		pnode = Document.find(:first, :conditions => ["name = ?", k])
		pnode.reorder_children(v)
	end
	do_logic_orders
end

def connect(connection)
	ActiveRecord::Base.establish_connection(connection)
	do_reorder
	ActiveRecord::Base.remove_connection
end

def reorder_trees
	connection_data = YAML.load(File.open($config_prefix + "database.yml"))
	["development"].each do #, "test"].each do
		|db|
		$stderr.printf("%%%%%% DATABASE: %s %%%%%%%%\n", db)
		connect(connection_data[db])
	end
end

reorder_trees
