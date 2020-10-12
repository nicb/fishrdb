# Uninstall hook code here
#
# $Id: uninstall.rb 539 2010-09-05 15:53:58Z nicb $
#
require 'ftools'
require File.dirname(__FILE__) + '/lib/environment'

#
# remove migration wrappers
#
MIGRATE_INSTALL_FILE_LIST.each do
  |src|
  dest = File.join(MIGRATE_DESTINATION, File.basename(src))
  begin
    res = File.unlink(dest)
  rescue => msg
    $stderr.puts("removal of file #{dest} failed: #{msg}")
  end
end
