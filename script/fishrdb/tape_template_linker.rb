#
# $Id: tape_template_linker.rb 551 2010-09-10 20:48:21Z nicb $
#

require 'ftools'

PRIVATE_ROOT= File.join(File.dirname(__FILE__), '..', '..', 'public', 'private')
TAPE_LIST_FILE= File.join(PRIVATE_ROOT, 'tape_lofi.list.txt')
tape_files = []
TAPE_TEMPLATE_SRC= File.expand_path(File.join(PRIVATE_ROOT, 'lofi_templates', 'template', 'template-file.mp3'))
TAPE_TEMPLATE_DST= File.expand_path(File.join(PRIVATE_ROOT, 'lofi_templates'))
TAPE_TEMPLATE_LNK= File.expand_path(File.join(PRIVATE_ROOT, 'lofi'))

class TapeFileName

  attr_reader :filename, :dirname

  def initialize(f)
    f.chomp!
    @filename = File.basename(f)
    @dirname  = File.dirname(f)
  end

  class SymbolicLinkFailed < StandardError; end

  def link
    File.makedirs(destination_dir)
    res = File.symlink(TAPE_TEMPLATE_SRC, destination_filename)
    raise(SymbolicLinkFailed, "#{self.verbose} symbolic linking failed") unless res
  end

  class <<self

    def file_parser(tlf)
      result = []
      File.open(tlf, 'r') do
        |fh|
        while (line = fh.gets)
          unless (line =~ /^\s*#/ || line =~ /^\s*$/)
            tfn = TapeFileName.new(line)
            result << tfn
          end
        end
      end
      return result
    end

  end

  def inspect
    return "#{self.class.name}(#{self.object_id}): source dir #{self.dirname}, source file #{self.filename}"
  end

  def verbose
    return "#{TAPE_TEMPLATE_SRC} => #{destination_filename}"
  end

private

  def destination_dir
    return File.expand_path(File.join(TAPE_TEMPLATE_DST, self.dirname))
  end

  def destination_filename
    return File.join(destination_dir, self.filename)
  end

end

tape_files = TapeFileName.file_parser(TAPE_LIST_FILE)
tape_files.each do
  |tf|
  puts(tf.verbose)
  tf.link
end

File.unlink(TAPE_TEMPLATE_LNK) if File.exists?(TAPE_TEMPLATE_LNK)
File.symlink(File.join(TAPE_TEMPLATE_DST, 'tapes_lofi'), TAPE_TEMPLATE_LNK)

exit(0)
