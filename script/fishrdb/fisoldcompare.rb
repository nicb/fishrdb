#!/usr/bin/env ruby
#
# $Id: fisoldcompare.rb 143 2008-01-26 00:16:57Z nicb $
#

top_prefix = File.expand_path(File.dirname(__FILE__) + '/../..')
lib = top_prefix + '/lib/'

require lib + 'fisold_compare_lib'

if ARGV.size != 1
	$stderr.puts("Usage: script/fishrdb/fisoldcompare.rb db")
else
	driver = File.basename(__FILE__)
	compare_db(driver, File.dirname(__FILE__) + '/../../tmp', ARGV)
end
