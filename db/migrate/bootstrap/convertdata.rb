#!/usr/bin/env ruby
# 
# $Id: convertdata.rb 113 2007-12-18 18:50:11Z nicb $
#
# This script uses ActiveRecord and it is used to convert from the old
# database schema to the new one. Running it should produce...
#
require 'fisold'
require 'connection_helper'
require 'score_tree_helper'

include ConnectionHelper
include ScoreTreeHelper

#
# SCORES
#
CONVERT_FISOLD_SCORE_ORDER_TABLE =
{
	"logic" 	=>  "anno_composizione", # there's no position in the old db
	"alpha"		=>  "titolo_fascicolo",
	"timeasc"	=>  "anno_composizione",
	"timedesc"	=>  "anno_composizione DESC",
	"position"	=>	"titolo_fascicolo", # there's no corda in the old db
}

def convert_fisold_score_order(dborder)
	return CONVERT_FISOLD_SCORE_ORDER_TABLE[dborder]
end

def create_score_record(r, parent, u, pos, dl, ct)
	result = nil

	if r.titolo_fascicolo
		begin
			result = Score.create!(:parent => parent, :name => r.titolo_fascicolo,
				:tipologia_documento_score => r.tipologia_documento, :misure_score => r.misure,
				:consistenza => r.consistenza, :autore_score => r.autore,
				:organico_score => r.organico, :anno_composizione_score => r.anno_composizione,
				:edizione_score => r.edizione, :anno_edizione_score => r.anno_edizione,
				:luogo_edizione_score => r.luogo_edizione, :trascrittore_score => r.trascrittore,
				:description => r.descrizione_contenuto, :note_score => r.note,
				:autore_versi_score => r.autore_versi,
				:titolo_uniforme_score => r.titolo_uniforme,
				:description_level => dl, :container_type => ct,
				:creator => u, :last_modifier => u,
				:position => pos)
			rescue
				$stderr.puts("create_score_record(#{r.inspect}, #{parent.inspect}, #{u.inspect}, #{dl.inspect}, #{ct.inspect}, #{pos}) failed: #{$!}")
				exit(-1)
		end
	else
		$stderr.puts("\tGOT AN EMPTY SCORE: '#{r.inspect}'. Ignoring.")
	end

	return result
end

def leaf(record, parent, dl, ct, u, pos=1)
	saved_record = create_score_record(record, parent, u, pos, dl, ct)
	record.children.each_index do
		|i|
		leaf(record.children[i], saved_record, dl, ct, u, i)
	end if record.children
end

def traverse(tree, parent, dl, ct, u)
	tree.each_value do
		|r|
		leaf(r, parent, dl, ct, u)
	end
end

def convert_all_scores(table)
	table.each do
		|t|
		tab = t[1]
		top_parent = Document.find_by_name(tab["parent"])
		begin
			dl = DescriptionLevel.find(:first, :conditions => ["level = ?", "Fascicolo"]) # missing in the scores!
			ct = ContainerType.find(:first, :conditions => ["container_type = ?", ''])
			u  = User.find(:first, :conditions => ["login = ?", "bootstrap"])
			klass = Fisold::ScoreCollection.index(tab['parent'])
			#
			# build the score tree
			#
			tree = build_tree(klass)
			#
			# traverse it and create document records
			#
			traverse(tree, top_parent, dl, ct, u)
			#
		rescue ActiveRecord::RecordNotFound => details
			$stderr.print  "Score reparenting, something did not work out properly:\n" + details.message + "\n" + details.backtrace.join("\n") + "\n"
			exit(-1)
		end
	end
end

#
# SERIES
#
def create_series_record(r, p, u, dl, ct, pos)
	if r.Titolo_Fascicolo
		begin
			result = Series.create!(:parent => p,
				:name => r.Titolo_Fascicolo, :description_level => dl,
				:consistenza => r.Consistenza, :data_dal => r.DataDal, :data_al => r.DataAl,
				:description => r.Descrizione_contenuto,
				:container_type => ct, :position => pos,
				:nota_data => r.Nota_Data, :data_topica => r.Luogo,
				:creator => u, :last_modifier => u
			)
		rescue
			$stderr.puts("create_series_record(#{r.inspect}, #{p.inspect}, #{u.inspect}, #{dl.inspect}, #{ct.inspect}, #{pos}) failed: #{$!}")
			exit(-1)
		end
	else
		$stderr.puts("\tGOT AN EMPTY RECORD: #{r.inspect}")
		result = nil
	end

	return result
end

def get_real_series_parent(r, grandparent, u, ct, pos)
	result = grandparent
	if r.Sottoserie?
		ssp = Document.find(:first, :conditions => ["name = ? and parent_id != ?", r.Sottoserie, 1]) # UGLY SPECIAL CASE :(
		if !ssp
			$stderr.printf("Series \"%s\" not found, allocating a new one\n", r.Sottoserie)
			dl = DescriptionLevel.find(:first, :conditions => ["level = ?", "SottoSerie"])
			ssp = create_series_record(r, grandparent, u, dl, ct, pos)
		end
		result = ssp
	end

	return result
end

def convert_each_series_record(r, parent, pos)
	if dl = DescriptionLevel.find(:first, :conditions => ["level = ?", r.Livello_gerarchico])
		ct = ContainerType.find(:first, :conditions => ["container_type = ?", ''])
		u  = User.find(:first, :conditions => ["login = ?", "bootstrap"])
		rp = get_real_series_parent(r, parent, u, ct, pos)
		result = create_series_record(r, rp, u, dl, ct, pos)
	else
		$stderr.puts("\tGOT AN EMPTY DL for record #{r.inspect}! Ignoring.")
		result = nil
	end

	return nil
end

CONVERT_FISOLD_SERIES_ORDER_TABLE =
{
	"logic" 	=>  "DataDal", # there's no position in the old db
	"alpha"		=>  "Titolo_Fascicolo",
	"timeasc"	=>  "DataDal",
	"timedesc"	=>  "DataDal DESC",
	"position"	=>	"DataDal", # there's no corda in the old db
}

def convert_fisold_series_order(dborder)
	return CONVERT_FISOLD_SERIES_ORDER_TABLE[dborder]
end

def convert_all_series(table)
	table.each do
		|t|
		tab = t[1]
		begin
			parent = Document.find_by_name(tab["parent"])
			order = convert_fisold_series_order(parent.children_ordering)
			klass = Fisold::SeriesCollection.index(tab['parent'])
			if klass
				n = 1;
				objects = klass.find(:all, :order => order)
				objects.each { |r| convert_each_series_record(r, parent, n); n += 1; }
			else
				$stderr.puts("\tFISOLD CLASS NOT FOUND FOR NAME #{tab['parent']}. Continuing...")
			end
		rescue ActiveRecord::RecordNotFound
			$stderr.printf("Parent: \"%s\" not found. Exiting.", tab["parent"])
			exit(-1)
		end
	end
end

def convert_series_data(fisold)
	convert_all_series(fisold["series"])
end

def convert_score_data(fisold)
	convert_all_scores(fisold["scores"])
end

def convert_data
	conns = ["development"]#, "test"]#, "production"]
	fisold	= YAML.load(File.open("data/yml/fisold.yml"))
	connection_data = YAML.load(File.open($config_prefix + "database.yml"))
	conns.each do
		|c|
		set_connections(connection_data[c], connection_data["fisold"])
		convert_series_data(fisold)
		convert_score_data(fisold)
		reset_connections
	end
end

convert_data
