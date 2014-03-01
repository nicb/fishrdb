#
# $Id: 20130909-find_potential_ars.rb 637 2013-09-10 12:56:40Z nicb $
#
require 'lib/debugger'
require 'config/environment'

def search(term)
  SearchEngine::Search.search_documents(term)
end

def yaml_string(ar)
  found = search(ar.display)
  res = <<-EOF
ar_#{"%05d" % ar.id}:
  id: #{ar.id}
  type: #{ar.type}
  name: #{ar.display}
  children_count: #{ar.children_count}
EOF
  if ar.accepted_form != ar
    res << "  accepted_form: [\"#{ar.accepted_form.display}\", (#{ar.accepted_form.id})]\n"
  end
  unless found.empty?
    strings = found.map { |d| "\"#{d.type}(\\\"#{d.to_s}\\\")(#{d.id})\"" unless d == ar }.compact
    res << "  potenzialmente_interessati: [#{strings.join(', ')}]" unless strings.empty?
  end
	res
end

ars = AuthorityRecord.all(:order => 'type,id').map { |ar| ar unless (ar.ard_references(true).count > 0) }.compact
ars.each { |ar| puts(yaml_string(ar)) }

