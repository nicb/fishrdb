#
# $Id: test_tape_lookup.rb 418 2009-07-03 23:06:41Z nicb $
#
# this must be run agains the production database
#
# cat this_file.rb | ruby script/console production
#

class TapeNotFound < StandardError
end

trs = TapeRecord.all

trs.each do
	|t|
	raise TapeNotFound.new("#{t.name} has no soundfiles!") if t.sound_collection.empty?
end
