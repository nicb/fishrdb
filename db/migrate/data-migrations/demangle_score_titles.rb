#!/usr/bin/env ruby
#
# $Id: demangle_score_titles.rb 164 2008-02-10 05:54:21Z nicb $
#

top_prefix = File.dirname(__FILE__) + '/../../..'
$:.unshift top_prefix + '/lib/'
require 'score_title_demangle'

require 'getoptlong'

include ScoreTitleDemangle

opts = GetoptLong.new(
  ["--rollback", "-r", GetoptLong::NO_ARGUMENT],
  ["--analyze_only", "-a", GetoptLong::NO_ARGUMENT]
)

func = ScoreTitleDemangle.method(:up)
begin
  opts.each do
    |opt, arg|
    case opt
    when '--rollback'
      func = ScoreTitleDemangle.method(:down)
    when '--analyze_only'
      func = ScoreTitleDemangle.method(:analyze_only)
    end
  end
rescue
  $stderr.puts("Usage: #{File.basename(__FILE__)} [--rollback|-r]")
  exit(-1)
end

func.call
exit(0)
