#!/usr/bin/env ruby
#
# $Id: 20080126-wrong_record_names.rb 327 2009-03-09 21:34:37Z nicb $
#

require 'yaml'

begin
	file = YAML.load(File.open(ARGV[0], 'r'))
rescue Errno::ENOENT => fnf
	$stderr.puts("#{fnf}")
	exit(-1)
end

count = 0
all_names = file.values.map { |v| v['name'] }
unique_list = all_names.sort.uniq.map { |x| [x, (all_names.select { |xx| xx == x }).size] }
unique_list.map { |i| count += i[1]; printf("\t%3d\t%s\n", i[1], i[0]) }
printf("Totale:\t%3d\tschede da cambiare\n", count)

exit(0)
