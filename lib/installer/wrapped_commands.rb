#
# $Id: wrapped_commands.rb 551 2010-09-10 20:48:21Z nicb $
#

require 'safe_delete'
require 'rm_minus_r'

module Installer

  module WrappedCommands

    class CommandFailed < StandardError; end

    def getwd
      return common_wrapper('Dir.getwd')
    end

    def chdir(dir)
      return common_wrapper("Dir.chdir(\"#{dir}\")")
    end

    def system(string)
      result = common_wrapper("Kernel::system(\"#{string}\")")
      raise(CommandFailed, string + ' failed') unless result
      return result
    end

    def symlink(src, dest)
      return common_wrapper("File.symlink(\"#{src}\",\"#{dest}\")")
    end

    def unlink(file)
      return common_wrapper("File.unlink(\"#{file}\")")
    end

    def unlink_dir(dir)
      return common_wrapper("rm_minus_r(\"#{dir}\")")
    end

  private

    def common_wrapper(string)
      result = nil
      report("Running #{string}...")
      bench = Benchmark.measure do
        result = eval(string)
      end
      report("Done #{string} => #{result} (#{bench.format("%.6r")} secs)")
      return result
    end

    STRING_HEADER = '>>>> '

    def report(string)
      Installer::Logger.info(STRING_HEADER + string)
    end

  end

end
