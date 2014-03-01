#!/usr/bin/env ruby
#
# $Id: reindex.cron.rb 548 2010-09-08 23:25:05Z nicb $
#
# this script should be added to the crontab file of the production machine
# with a line like this:
#
# 33 4 *  *  *     $FISHRDB_PRO_PATH/reindex.cron.rb
#
# (this will run the reindexer every night at 4:33 AM)
#
ENV['RAILS_ENV'] ||= 'production'

RAILS_ROOT = File.join(File.dirname(__FILE__), '..', '..')
require File.join(RAILS_ROOT, 'config', 'environment')
require File.join('search_engine', 'index_builder')

SearchEngine::IndexBuilder::Builder.build

exit(0)
