#
# $Id: constants.rb 636 2013-07-26 15:27:28Z nicb $
#

module Installer

  class Rails

    DEFAULT_RAILS_VERSION = '2.1.0'
    RAILS_ROOT = File.join(File.dirname(__FILE__), '..', '..')
    VENDOR_DIR = File.join(RAILS_ROOT, 'vendor')
    PLUGIN_DIR = File.join(VENDOR_DIR, 'plugins')
    RAILS_DIR = File.join(VENDOR_DIR, 'rails')
    RAILS_GIT_URL = 'git://github.com/rails/rails.git'
		#
		# Please do not include +will_paginate+ in this plugin list, as it
		# cannot be installed any longer from source (incompatible with rails <
		# 2.3)
		#
    FISHRDB_DEFAULT_PLUGINS = %w(acts_as_tree acts_as_list auto_complete)

  end

end
