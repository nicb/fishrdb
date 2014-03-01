#
# $Id: split.rb 598 2011-01-04 07:35:09Z nicb $
#
# This helper requires the following software to be installed on the host
# system:
#
# - mp3splt
# - mp3check
#

require 'fishrdb_helper'

module Mp3Helper

  module Split

    include FishrdbHelper::Lofi

    def generate_segment(srcfile, destdir, start_time, end_time, segments)
      raise(MissingData, "data missing for generate_segment(\"#{srcfile}\", \"#{destdir}\", \"#{start_time}\", \"#{end_time}\", \"#{segments}\")") unless srcfile && destdir && start_time && end_time && segments
      file = srcfile =~ /#{LINEAR_FILE_SUFFIX}$/ ? reference_file(srcfile) : srcfile
      process = "mp3splt -Q -d \"#{destdir}\" -o '@f-#{segments}' \"#{self.source_path}/#{file}\" #{start_time.to_mp3splt} #{end_time.to_mp3splt}"
      res = Kernel::system(process)
      raise(SystemCallFailure, "#{process} failed (code: #{$?})") unless res
      res
    end

  end

end
