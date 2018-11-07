#
# $Id: tapes.rake 551 2010-09-10 20:48:21Z nicb $
#

require 'rm_minus_r'

namespace :db do
  namespace :tapes do

    desc "Create all ActiveRecord Tape records and insert them in db"
    task :create => :environment do

      ENV['FISHRDB_SESSION_NEEDED'] = 'true'
      Tdp::Tape::Mapper.create_tape_records_from_scratch

    end

    desc "Drop all ActiveRecord Tape records from db"
    task :drop => :environment do

      Tdp::Tape::Mapper.drop_tape_records

    end
  end
end

namespace :tapes do
  namespace :lofi do
    desc "Create the low-definition copies for all audio and images files (requires 'lame' and 'imagemagick')"
    task :create => ['tapes:lofi:create:audio', 'tapes:lofi:create:images']
    namespace :create do
      desc "Create the low-definition copies for all audio files (requires 'lame')"
      task :audio do
        audio_dir = '/Audio Files'
        create_lofi_copy(audio_dir) do
          |md|
          afmd = md + audio_dir
          Dir[afmd + '/*.*'].sort.reverse.each do
            |af|
            bit_rates = [128, 56]
            lopath = af.lofi_path
            lofile = File.basename(lopath)
            lodir = File.dirname(lopath)
            bit_rates.each do
              |br|
              mp3file = lofile.sub(/\.aif\Z/, "-#{br}.mp3")
              mp3path = lodir + '/' + mp3file
              unless File.exists?(mp3path)
                puts("     +--> create #{mp3file.sub(/\A.*\/NMGS/, 'NMGS')}")
                lame_options= ENV['LAME_OPTIONS'] ? ENV['LAME_OPTIONS'] : ''
                syscall = "lame #{lame_options} -cob #{br} \"#{af}\" \"#{mp3path}\""
                res = system(syscall)
                raise "process \"#{syscall}\" failed" unless res
              end
            end
          end
        end
      end
      desc "Create the low-definition copies for all image files (requires 'convert' from the 'imagemagick' suite)"
      task :images => :environment do
        image_dir = '/Images'
        create_lofi_copy(image_dir) do
          |md|
          imgd = md + image_dir
          Dir[imgd + '/*.*'].sort.reverse.each do
            |img|
            rez = ['768', '128']
            lopath = img.lofi_path
            lofile = File.basename(lopath)
            lodir = File.dirname(lopath)
            rez.each do
              |r|
              rfile = lofile.sub(/\.\w{3,8}\Z/, "-#{r}.jpg")
              rpath = lodir + '/' + rfile
              unless File.exists?(rpath)
                puts("          +--> converting #{File.basename(img)} to #{r} resolution")
                conv_command = "gm convert -geometry #{r} '#{img}' '#{rpath}'"
                res = system(conv_command)
                raise "process \"#{conv_command}\" failed" unless res
              end
            end
          end
        end
      end
    end
    desc "Remove all low-definition copies"
    task :clear => :environment do
      puts("removing files below #{base_path.lofi_path}")
      Dir[base_path.lofi_path].each do
        |root_dir|
        rm_minus_r(root_dir)
      end
    end
  end
end

def base_path
  tree_pattern_pfx = "/../../public/private"
  tree_pattern_sfx = '/[0-9]*'
  result = File.dirname(__FILE__) + tree_pattern_pfx + '/hifi' + tree_pattern_sfx
  return result
end

def create_lofi_copy(dest_subdir, &block)
  #
  # for each hifi high-level dir (i.e. each RAID set found)
  # 
  Dir[base_path].sort.reverse.each do
    |dir|
    #
    # create the corresponding lowfi directory (if it does not exist yet)
    # Ex.: private/hifi/1  --> private/lofi/1
    #
    # FIXME: this passage is now skipped because we don't have the intermediate RAID directory any longer
    #
    # lodir = dir.lofi_path
    # lodir.conditional_mkdir
    #
    # create all numbered subdirs inside the lofi directory (if they do
    # not exist yet)
    # Ex: private/hifi/1/0001-0020 -> private/lofi/1/0001-0020
    #
    # FIXME: this is skipped too
    #
    # Dir[dir + '/[0-9]*-[0-9]*'].sort.reverse.each do
    # |sdir1|
    # lodir = sdir1.lofi_path
      lodir = dir.lofi_path
      lodir.conditional_mkdir(2)
      #
      # enter in each first level subdir and access each second level
      # subdir (and create it if it does not exist)
      # Ex: private/hifi/1/0001-0020/NMGS0001-* -> private/lofi/1/0001-0020/NMGS0001-*
      #
      Dir[dir + '/NMGS*'].sort.reverse.each do
        |sdir2|
        lodir = sdir2.lofi_path
        lodir.conditional_mkdir(3)
        md = lodir + dest_subdir
        md.conditional_mkdir(4)
        yield(sdir2)
      end
    # end
  end
end

#
# String Extensions
#

class String

  def lofi_path
    return sub(/hifi/, 'lofi')
  end

  def conditional_mkdir(tabs = 1)
    tabss = "  " * tabs
    unless File.exists?(self)
      puts(tabss + "+--> create directory #{self.sub(/\A.*\/NMGS/,'NMGS')}")
      Dir.mkdir(self)
    end
  end

end
