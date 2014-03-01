#
# $Id: bundle_generator.rb 596 2011-01-03 08:50:36Z nicb $
#
# +BundleGenerator+ generate packages of tapes + tape info (protools session
# text, images, etc.) following a description given on a yaml file passed as
# argument. The fields of the yaml file are organized as follow:
#
# system: # this is a mandatory set
#   format:       targz  # should have: targz, zip (optional, default: targz)
#   output_filename: <name> 
#
# NMGS0123-348:  # tag (which gets translated into a directory name)
#   files: [ Riv@19-L-128.mp3, Riv@9,5-RVRS-R-128.mp3 ] # files to be included
#                                                       # (if no files field is included, 
#                                                       # all 128 br mp3 files are
#                                                       # included)
#  images: [ Snapshot348-768.tiff, 348_001-768.jpg ]    # images to be included
#                                                       # (if no images field is included,
#                                                       # all 768 px files are
#                                                       # included)
#  fragments: [ A0-A12, B23 ]                           # fragments generated
#                                                       # as separate 128 br mp3 files
#  time_fragments: [ [<file>, [00:03, 12:28.5]], [ <file>, [18:23, 19:36]] ] # absolute
#                                                       # reference time fragments to be generated
#                                                       # as separate 128 br mp3 files
#

RAILS_ENV = 'production' unless defined?(RAILS_ENV)

require 'fishrdb_helper'
require 'mp3_helper'

BUNDLE_GENERATOR_PATH = File.join(File.dirname(__FILE__), 'bundle_generator')
%w(
  exceptions
  shouter
  bundle_file
  tape_segment
  time_segment
  tape
  system
  bundle
  file_parser
  driver
).each { |rqfile| require File.join(BUNDLE_GENERATOR_PATH, rqfile) }
