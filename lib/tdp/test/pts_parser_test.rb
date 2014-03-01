#
# $Id: pts_parser_test.rb 373 2009-04-19 15:31:15Z nicb $
#
pts_test_cwd = File.dirname(__FILE__)
require 'yaml'
require pts_test_cwd + '/../pro_tools/data_aggregator'

if ARGV.size != 1
  $stderr.puts("Usage: #{$0} <file name>")
  exit(-1)
end

da = Tdp::ProTools::DataAggregator.new(ARGV[0])
da.parse

fh = File.open(pts_test_cwd + '/pts_test_output.yml', 'w')
YAML.dump(da, fh)
fh.close
