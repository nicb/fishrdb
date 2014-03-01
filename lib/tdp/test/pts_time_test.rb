require 'data_aggregator'

st = Tdp::ProTools::SessionTime.create('41:04.339')
et = Tdp::ProTools::SessionTime.create('69:58.655')
diff = et - st

new_et = st + diff

puts(st.inspect)
puts(et.inspect)
puts(diff.inspect)

raise "Wow! addition and subtraction do not coincide!" unless new_et == et
puts(new_et.inspect)

puts(et.to_sec.to_s)

