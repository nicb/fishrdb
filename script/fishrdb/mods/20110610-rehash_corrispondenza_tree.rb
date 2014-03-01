#
# $Id: 20110610-rehash_corrispondenza_tree.rb 612 2011-06-13 02:09:14Z nicb $
#
RAILS_ROOT = File.join(File.dirname(__FILE__), ['..'] * 3)
require File.join(RAILS_ROOT, 'config', 'environment')

require 'alphabetizer'

#
# add debugger (uncomment the next line) if needed
#
# require 'debugger'

folder_name = 'Corrispondenza'
uname = 'bootstrap'
ct_type = 'scatola'

alph = Alphabetizer.new(uname, ct_type, folder_name)
alph.alphabetize
