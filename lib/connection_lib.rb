#
# $Id: connection_lib.rb 174 2008-02-22 22:00:29Z nicb $
#

top_prefix 			= File.expand_path(File.dirname(__FILE__) + '/..')
$:.unshift top_prefix + '/config/'
require 'environment'
require 'active_record'

module ConnectionLib
	module ConnectionLibraryClassMethods
	
	public
	
		def open_db(db)
			result = self.establish_connection(db.intern) || raise("Connection to #{db} failed")
		end
	
		def close_db
			self.remove_connection
		end
	
	end
end
	
class Document < ActiveRecord::Base
  include ConnectionLib::ConnectionLibraryClassMethods
  extend  ConnectionLib::ConnectionLibraryClassMethods
end
	
class Fisold < ActiveRecord::Base
  include ConnectionLib::ConnectionLibraryClassMethods
  extend  ConnectionLib::ConnectionLibraryClassMethods
end

class FisoldGS < Fisold
  set_table_name 'Partiture_Scelsi'
end

class FisoldAA < Fisold
  set_table_name 'Partiture_altri_autori'
end
