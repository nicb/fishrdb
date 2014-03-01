#
# $Id: rails.rb 636 2013-07-26 15:27:28Z nicb $
#

module Installer

  class Rails
    attr_reader :version, :environment, :plugin_list


    include Installer::WrappedCommands
    include Installer::Plugins

    def initialize(e = nil, v = DEFAULT_RAILS_VERSION, plist = [])
      ENV['RAILS_ENV'] = @environment = e || ENV['RAILS_ENV'] || 'production'
      @version = v
      @plugin_list = create_plugin_list(plist.empty? ? FISHRDB_DEFAULT_PLUGINS : plist)
    end

    def install
      #
      # DO NOT install rails any longer, it is no longer necessary
      # (nor possible)
      #
      # uninstall if File.exists?(RAILS_DIR) # if already installed, uninstall first
      #
      # orig_dir = getwd
      # chdir(VENDOR_DIR)
      #
      # system("git clone -q #{RAILS_GIT_URL}")
      #
      # chdir(RAILS_DIR)
      #
      # system("git checkout -q v#{DEFAULT_RAILS_VERSION}")
      #
      # chdir(orig_dir)
    
      self.plugin_list.each { |plug| plug.install }
    end

    def uninstall
      orig_dir = getwd

      chdir(VENDOR_DIR)
      unlink_dir(RAILS_DIR)

      chdir(orig_dir)

      self.plugin_list.each { |plug| plug.uninstall }
    end

  private

    def create_plugin_list(plist)
      result = []
      plist.each do
        |plug|
        result << Plugin.map(plug)
      end
      return result
    end

  end

end
