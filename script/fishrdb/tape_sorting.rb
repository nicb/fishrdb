#
#
# To be run from the console
#
# This is to attempt a mapping of all counters an numbers:
# BB counter, FMU counter, nicb counter
#
# the first two counters currently appear as such but in fact they are inverted
#
TapeData.all.sort do
 |a, b|
 [a.bb_inventory.to_i, a.inventory.to_i] <=> [b.bb_inventory.to_i, b.inventory.to_i]
end.map do
 |t|
 d = t.tape_record.description.gsub("\n", ' ').gsub(',', '_') if t.bb_inventory.empty?
 puts("#{t.bb_inventory},#{t.inventory},#{t.tape_record.name},#{d}")
end
