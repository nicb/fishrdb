#
# $Id: debugger.rb 572 2010-12-12 18:37:32Z nicb $
#
# add a debugger trace wherever you load this file
#
# FIXME: this doesn't work in rails 3.2.22.5 and has been no-opped
#
# require File.expand_path(File.join(['..'] * 2, 'config', 'constants'), __FILE__)
# require File.join(RAILS_ROOT, 'config', 'environment') unless defined?(ActiveRecord)
# require 'rubygems'
# require 'active_support'
# begin
#   require 'debugger'
#   Debugger.start
#   Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
# rescue LoadError
#   # ruby-debug wasn't available so neither can the debugging be
#   puts("could not load the debugger")
# end
