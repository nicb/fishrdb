#
# $Id: bundle.rb 599 2011-01-05 01:04:07Z nicb $
#
# The fields of the configuration file are organized as follow:
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
#  fragments: [ A0*-A12*, B23@9\,5 ]                    # fragments to be generated
#                                                       # as separate 128 br mp3 files
#                                                       # Note: if a segment is followed
#                                                       # by an '*', then it is
#                                                       # considered to be a pattern, otherwise it
#                                                       # is looked up literally
#  time_fragments: [ [00:03, 12:28.5], [18:23, 19:36] ] # absolute reference time fragments to be generated
#                                                       # as separate 128 br mp3 files
#
require File.join(File.dirname(__FILE__), '..', 'tdp', 'pro_tools', 'exceptions')

module BundleGenerator

  class Bundle < Base

    attr_reader :system, :tapes

    TMPDIR = File.join(File.dirname(__FILE__), '..', '..', 'tmp')

    def initialize(config)
      super(nil)
      (@system, @tapes) = create_bundle_data(config)
    end

    def generate
      result = nil
      pfx = "bundle_generator_#{$$}"
      Dir.mktmpdir(pfx, TMPDIR) { |tdir| result = generate_bundle(tdir) }
      dot
      result
    end

  private

    def create_bundle_data(config)
      tape_results = []
      sys_config_field = config.delete('system')
      raise(SystemConfigurationMissing) unless sys_config_field
      system_config = System.new(sys_config_field)
      config.keys.each do
        |t|
        begin
          tape_results << Tape.new(t, config[t])
	      rescue TaintingError, Tdp::ProTools::CatchableException => msg
          err_msg = "#{t}.txt #{msg}, continuing"
          self.shouter.say(err_msg)
	        system_config.taint
	        Rails::logger.error(err_msg)
	      end
      end
      dot
      [system_config, tape_results]
    end

    def create_tmp_dir
      curpath = "bundle_generator_#{$$}"
      tmpdir = File.join(TMPDIR, curpath)
      Dir.mkdir(tmpdir)
      dot
      tmpdir
    end

    def generate_bundle(tmpdir)
      self.tapes.each do
        |t|
        dest_path = File.join(tmpdir, t.name)
        Dir.mkdir(dest_path)
        t.create_tape_bundle(dest_path)
      end
      op = ''
      Dir.chdir(tmpdir) do
        op = generate_archive
        dot
      end
      Dir.chdir(TMPDIR) do
        op = generate_md5sum(TMPDIR, File.basename(op))
        dot
      end
      op
    end

    def generate_archive
      if (self.system.output_format == 'zip')
        op = generate_zip_archive
      else
        op = generate_targz_archive
      end
      op
    end

    def generate_md5sum(output_path, output_file)
      output = File.join(output_path, output_file)
      command = "md5sum #{output_file} > #{output}.md5"
      Kernel::system(command)
      output
    end

    def generate_archive_common
      output_path = File.join('..', self.system.output_filename)
      command = yield(output_path)
      Kernel::system("echo 'This bundle is INCOMPLETE!' > BROKEN_BUNDLE.README") if system.tainted?
      Kernel::system(command)
      output_path
    end

    def generate_targz_archive
      generate_archive_common { |op| "tar czf #{op} *" }
    end

    def generate_zip_archive
      generate_archive_common { |op| "zip -qr #{op} *" }
    end

  end

end
