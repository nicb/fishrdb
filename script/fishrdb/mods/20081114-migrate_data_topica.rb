#
# $Id: 20081114-migrate_data_topica.rb 327 2009-03-09 21:34:37Z nicb $
#
# this is the driver for the Data Topica Migration, used in conjunction with the
# 'lib/migrate_nota_data.rb' library. The library and the driver are
# idempotent, so they can be used only once. Use as:
#
# cat <file> | ruby script/console production
#

mnd = MigrateNotaData.new

mnd.process_data_topica
