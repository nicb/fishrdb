#!/usr/bin/env ruby
#
# $Id: cleanse-db.rb 41 2007-10-29 12:09:30Z nicb $
#
#
# The cleanse function does all the work. Anything required to be
# corrected/cleaned etc. should be put here.
#
def cleanse(l)
	l = l.gsub(/Nota_data/, "Nota_Data")
	l = l.gsub(/Livelo_gerarchico/, "Livello_gerarchico")
	l = l.gsub(/Opsucoli/, "Opuscoli")
	l = l.gsub(/Opuscolo/, "Opuscoli")
	l = l.gsub(/contabili-mministrativi/, "contabili-amministrativi")
	l = l.gsub(/'Eventi'/,"'Eventi musicali'")
	l = l.gsub(/Brochure e dépliant/,"Brochures e dépliants")
	l = l.gsub(/'Manifesti'/,"'Manifesti e locandine'")
	l = l.gsub(/anno_di_edizione/,"anno_edizione")
	return l
end

def reader(file)
	begin
		full_line = ''
		n = 0
		fh = File.open(file)
		fh.read.each do
			|line|
			n += 1
			if line !~ /^--/ || !full_line.empty?
			then
				full_line = full_line + line
				next unless full_line =~ /\);$/
				l = full_line.chop
				l = cleanse(l)
				puts(l)
				full_line = ''
			else
				puts(line)
			end
		end
	rescue RuntimeError => kaboom 
		$stderr.printf("Runtime error: %s at line %d\n", kaboom, n)
	ensure
		fh.close
	end
end

ARGV.each { |arg| reader(arg) }
