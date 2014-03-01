#
# $Id: hash_extensions.rb 470 2009-10-18 16:18:58Z nicb $
#
# Extensions to the Hash class
#

module HashExtensions

  def read_and_delete(key, result = nil)
    result = delete(key) if has_key?(key)
    return result
  end

  def read_and_delete_returning_empty_if_null(key)
    return read_and_delete(key, '')
  end

public

  #
  # transfer(keys)
  # transfers a key-value pair set from one hash to another
  #
  def transfer(*key_set)
    result = {}
    key_set.each { |ks| transfer_key(ks, result) } unless blank_values?
    return result 
  end

private

  def transfer_key(key, dest_hash)
	  dest_hash.update(key => read_and_delete(key)) if has_key?(key)
  end

public
  #
  # blank_values? returns true iff all values are blank?
  #
  def blank_values?
    result = true
    values.each do
      |v|
      unless v.blank?
        result = false
        break
      end
    end
    return result
  end
  
end

class Hash
  include HashExtensions
end
