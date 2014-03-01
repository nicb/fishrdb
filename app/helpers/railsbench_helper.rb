#
# $Id: railsbench_helper.rb 136 2008-01-08 19:07:40Z nicb $
#

module RailsbenchHelper
	#
	# attempt to use railsbench (still using old rails constructs)
	#
	def render_text(string, more_string)
		render(:text => string + more_string)
	end
end
