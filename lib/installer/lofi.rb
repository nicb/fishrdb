#
# $Id: lofi.rb 551 2010-09-10 20:48:21Z nicb $
#

module Installer

  module Lofi

		PRIVATE_DIR = File.join(Rails::RAILS_ROOT, 'public', 'private')
		LOFI_SRCDIR = File.join('..', '..', '..', '..', 'tapes_lofi')
		LOFI_DSTLNK = 'lofi'

    include Installer::WrappedCommands

		def link_lofi_to_nas
		  orig_dir = getwd
		
		  chdir(PRIVATE_DIR)
		  unlink(LOFI_DSTLNK)
		  symlink(LOFI_SRCDIR, LOFI_DSTLNK) 
		
		  chdir(orig_dir)
		end
    
		def unlink_lofi_to_nas
		  orig_dir = getwd
		
		  chdir(PRIVATE_DIR)
		  unlink(LOFI_DSTLNK)
		
		  chdir(orig_dir)
		end
    
  end

end
