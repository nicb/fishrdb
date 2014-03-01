#!/usr/bin/env ruby
# 
# $Id: print_score_tree.rb 113 2007-12-18 18:50:11Z nicb $
#
# This script is needed to verify that the parenthood of the Giacinto Scelsi
# scores is correct
#

require 'fisold'
require 'connection_helper'
require 'score_tree_helper'

include Fisold
include ConnectionHelper
include ScoreTreeHelper

#
# adding children capabilities to the GS class
#
class Fisold::ScoresGiacintoScelsi < Scores
	TRUNCATE_VALUE = 67
	attr_accessor :printing_prefix

	def initialize
		super
		@printing_prefix = ''
	end

protected
	def self.truncate(string, v=TRUNCATE_VALUE)
		result = string.size > v ? string[0..v] + "..." : string
	end

	def self.nulled(string)
		return string ? string : ""
	end

	def short_title
		return self.class.truncate(titolo_fascicolo)
	end

	def organico
		k = self.class
		return k.truncate(k.nulled(read_attribute(:organico)))
	end

	def note
		k = self.class
		result = k.nulled(read_attribute(:note))
		return k.truncate(result)
	end

	def print_output(string)
		puts(string)	
	end

	def to_s
		k = self.class
		fields = [ "contatore", "figlia_di", "tipologia_documento", "organico", "consistenza", "note" ]
		result = "Scheda: " + k.nulled(printing_prefix) + titolo_fascicolo + "\n"
		fields.each do
			|s|
			field = send(s).to_s.gsub(/\n/, ' ')
			result = result + k.nulled(printing_prefix) + "    " + sprintf("%-25s: ", s) + field + "\n" unless !field or field.empty?
		end
		return result
	end

	def do_print(head, &block)
		print_output(head)
		if children
			sorted_children = children.sort { |a, b| a.contatore <=> b.contatore }
			sorted_children.each do
				|c|
				c.printing_prefix = self.class.nulled(printing_prefix) + '    '
				yield(c)
			end
		end
	end

public

	def print
		k = self.class
		do_print(k.nulled(printing_prefix) + self.to_s) { |c| c.print }
	end

	def print_index
		k = self.class
		to_be_printed = k.nulled(printing_prefix) + sprintf("%4d: %s", contatore.to_s, short_title)
		to_be_printed = to_be_printed + ", figlia di " + figlia_di.to_s unless !figlia_di or figlia_di == 0
		do_print(to_be_printed) { |c| c.print_index }
	end

end

def print_header
	puts("\n\nTavola: \"#{Fisold::ScoresGiacintoScelsi.table_name}\"")
end

def print_footer
end

def print_tree(tree)
	print_header
	sorted_tree = tree.sort { |a, b| a[0].to_i <=> b[0].to_i }
	puts("========================================================================")
	puts("Indice:")
	sorted_tree.each { |pair| pair[1].print_index }
	puts("========================================================================")
	puts("Dettaglio:\n")
	sorted_tree.each do
		|pair|
		l = pair[1]
		puts("------------------------------------------------------------------------")
		l.print
		puts("------------------------------------------------------------------------\n\n")
	end
	print_footer
end


def print_genealogical_tree(&block)
	conns = ["development"]
	fisold	= YAML.load(File.open("data/yml/fisold.yml"))
	connection_data = YAML.load(File.open($config_prefix + "database.yml"))
	conns.each do
		|c|
		tree = {}
		set_connections(connection_data[c], connection_data["fisold"])
		begin
			tree = build_tree(Fisold::ScoresGiacintoScelsi)
		rescue
			bt = $@.join("\n\t\t")
			$stderr.puts("ERRORE (#{__FILE__} #{$!})\nBacktrace:\n\t\t#{bt}")
		end
		yield(tree)
		reset_connections
	end
end

print_genealogical_tree { |c| print_tree(c) }
