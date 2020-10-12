#
# $Id: test_helper.rb 552 2010-09-12 10:50:29Z nicb $
#
ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require 'test/unit'
require File.expand_path(File.join(ENV['RAILS_ROOT'], 'config', 'environment'))

require 'active_support/test_case'
require 'tape_name_caption'

begin
  require_library_or_gem 'ruby-debug'
  Debugger.start
  Debugger.settings[:autoeval] = true if Debugger.respond_to?(:settings)
rescue LoadError
  # ruby-debug wasn't available so neither can the debugging be
end
