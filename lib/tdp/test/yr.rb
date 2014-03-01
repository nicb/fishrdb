#
# $Id: yr.rb 369 2009-04-17 03:40:30Z nicb $
#
# Quick yaml reader
# this can be loaded in an irb session to reduce preamble typing
#

CWD = File.dirname(__FILE__)
require CWD + '/../tape'
require 'yaml'

fh = File.open(CWD + '/NMGS0194-294.yml')
@tape = YAML.load(fh)
