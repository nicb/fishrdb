#
# $Id: debugger.rb 572 2010-12-12 18:37:32Z nicb $
#
# add a debugger trace wherever you load this file
#
RAILS_ROOT = File.join(File.dirname(__FILE__), '..') unless defined?(RAILS_ROOT)
require File.join(RAILS_ROOT, 'config', 'environment') unless defined?(ActiveRecord)
require 'rubygems'
require 'active_support'
begin
  require_library_or_gem 'ruby-debug'
  Debugger.start
  Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
rescue LoadError
  # ruby-debug wasn't available so neither can the debugging be
  puts("could not load the debugger")
end
