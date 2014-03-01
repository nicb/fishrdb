#
# $Id: preload.rb 561 2010-11-27 21:30:08Z nicb $
#
# uncomment this line to enable debugging from the start
#
# require 'debugger'

Rails::logger.info(">>>> preloading required objects")

#
# Add all objects that require preloading to ensure that all reflections and
# associations are correctely loaded since early run time
#
# OLD NOTE: 'document' should be preloaded only if it is not called by 'rake' (during
# migrations, for example), because the inclusions break the migration process
#
# NEW NOTE: in fact, this has been commented out because the exclusion from
# rake calls create problems in fixture loading (however - these problems are
# still under investigation - 12/06/2010)
#
require RAILS_ROOT + '/app/models/document' # unless $0 =~ /rake$/
require RAILS_ROOT + '/app/models/sidebar_tree_item'
require RAILS_ROOT + '/app/models/sidebar_tree'
