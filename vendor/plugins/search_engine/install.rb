# Install hook code here
#
# $Id: install.rb 539 2010-09-05 15:53:58Z nicb $
#
require 'ftools'
require File.dirname(__FILE__) + '/lib/environment'

#
# copy migration wrappers
#
MIGRATE_INSTALL_FILE_LIST.each do
  |src|
  dest = File.join(MIGRATE_DESTINATION, File.basename(src))
  res = File.copy(src, dest)
  raise(StandardError, "Failed to copy #{src} into #{dest}") unless res
end
