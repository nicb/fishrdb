module Fishrdb

  module Stats

    PATH = File.expand_path(File.join('..', 'stats'), __FILE__)

  end

end

%w(
	output
  document_hierarchical_count 
  authority_count
).each { |f| require File.join(Fishrdb::Stats::PATH, f) }
