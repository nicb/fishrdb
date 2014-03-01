#!/usr/bin/env ruby
# 
# $Id: connection_helper.rb 113 2007-12-18 18:50:11Z nicb $
#

module ConnectionHelper

	require 'fisold'
	
	def set_connections(conn, fisold_conn)
		ActiveRecord::Base.establish_connection(conn)
		Fisold::Series.establish_connection(fisold_conn)
		Fisold::Scores.establish_connection(fisold_conn)
	end
	
	def reset_connections
		Fisold::Series.remove_connection
		ActiveRecord::Base.remove_connection
	end

end
