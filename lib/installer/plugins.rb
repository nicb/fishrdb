#
# $Id: plugins.rb 636 2013-07-26 15:27:28Z nicb $
#

module Installer

  module Plugins

    class Plugin

      include Installer::WrappedCommands

      attr_reader :name

      def initialize(n, options = {})
        @name = n
      end

      def install
        return system("ruby script/plugin install -q --force #{self.name}")
      end

      def uninstall
        return unlink_dir(File.join(Installer::Rails::PLUGIN_DIR, self.name))
      end

    end

    class MissingSandbox < StandardError; end

    class GitSandbox < Plugin

      attr_reader :sandbox

      def initialize(n, opts = {})
        raise(MissingSandbox, "#{n}") unless opts.has_key?(:sandbox)
        @sandbox = opts[:sandbox]
        return super(n)
      end

      def install
        return system("ruby script/plugin install -q --force #{self.sandbox}/#{self.name}")
      end

    end

    class Plugin

      class << self

        class UnknownPlugin < StandardError
          def initialize(msg)
            Installer::Logger.error("#{self.class.name} exception caught: " + msg)
          end
        end

        PLUGIN_CLASS_MAP =
        {
          'acts_as_tree' => { :klass => GitSandbox, :options => { :sandbox => 'git://github.com/rails' }},
          'acts_as_list' => { :klass => GitSandbox, :options => { :sandbox => 'git://github.com/rails' }},
          'auto_complete' => { :klass => GitSandbox, :options => { :sandbox => 'git://github.com/rails' }},
          #
          # The +will_paginate+ plugin does not work any longer with rails
          # versions < 2.3, so we are stuck with using the one that is saved
          # in the svn repository. The next line would actually overwrite that
          # version (and then break in deployment), so we comment it out
          #
          # 'will_paginate' => { :klass => GitSandbox, :options => { :sandbox => 'git://github.com/mislav' }},
        }

        def map(plug)
          raise(UnknownPlugin, "plugin #{plug} is not known to the FIShrdb system") unless PLUGIN_CLASS_MAP.has_key?(plug)
          k = PLUGIN_CLASS_MAP[plug]
          return k[:klass].new(plug, k[:options])
        end

      end

    end

  end

end
