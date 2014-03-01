#
# $Id: test_helper.rb 539 2010-09-05 15:53:58Z nicb $
#
ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config', 'environment'))

require 'active_support/test_case'

begin
  require_library_or_gem 'ruby-debug'
  Debugger.start
  Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
rescue LoadError
  # ruby-debug wasn't available so neither can the debugging be
end
