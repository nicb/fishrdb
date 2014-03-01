#
# $Id: safe_delete.rb 551 2010-09-10 20:48:21Z nicb $
#

class File

  class << self

	  alias_method :orig_delete, :delete
	
	  def delete(file)
      result = nil
      begin
        result = orig_delete(file)
      rescue StandardError
        #
        # nothing happens if the file does not exist
        #
      end
      return result
	  end

    alias_method :unlink, :delete

  end

end

class Dir

  class << self

	  alias_method :orig_delete, :delete
	
	  def delete(dir)
      result = nil
      begin
        result = orig_delete(dir)
      rescue StandardError
        #
        # nothing happens if the file does not exist
        #
      end
      return result
	  end

    alias_method :unlink, :delete

  end

end
