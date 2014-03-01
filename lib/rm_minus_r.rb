#
# $Id: rm_minus_r.rb 551 2010-09-10 20:48:21Z nicb $
#

require 'safe_delete'

def rm_minus_r(root)
  if File.exists?(root)
	  if File.directory?(root)
	    Dir[root + '/*', root + '/.[A-z0-9_\;+\-]*'].each do
	      |e|
	      rm_minus_r(e)
	    end
	    Dir.delete(root)
	  else
	    File.delete(root)
	  end
  end
end
