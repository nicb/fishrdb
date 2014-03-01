#
# $Id: environment.rb 539 2010-09-05 15:53:58Z nicb $
#


MIGRATE_DESTINATION = File.join(File.dirname(__FILE__), '..', '..', '..', '..', 'db', 'migrate')
MIGRATE_INSTALL_FILE_LIST = Dir.glob(File.join(File.dirname(__FILE__), '..', 'lib', 'db', 'migrate', 'install', '*'))
