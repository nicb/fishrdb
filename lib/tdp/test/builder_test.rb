#
# $Id: builder_test.rb 492 2010-04-18 09:54:00Z nicb $
#
require 'logger'
require 'lib/tdp/builder'
require 'yaml'

RAILS_ENV = ENV['RAILS_ENV'] || 'test' unless defined?(RAILS_ENV)

b = Tdp::Builder::TapeFactory.new('lib/tdp/test/ScelsiDataBase.csv')
b.build

fy = File.open('tmp/builder_dump.yml', 'w')
YAML.dump(b, fy)
fy.close
