#
# $Id$
#
class RenameDescriptionReservedToPublicAccess < ActiveRecord::Migration

  class << self

	  def set_attribute(doc, attrib, val)
      now = DateTime.now.to_s.sub(/T/,' ').sub(/\+.*$/,'')
      if val == true || val == false
        conditioned_val = val ? 1 : 0
      else
        conditioned_val = "'" + val.to_s + "'"
      end
      execute("update documents SET updated_at = '#{now}',
               lock_version = #{doc.lock_version+1}, #{attrib.to_s} = #{conditioned_val}
               WHERE id = #{doc.id} AND lock_version = #{doc.lock_version}")
      #
      # reloading the document and checking that the value is properly set
      # won't work here, don't ask me why :((
      #
      # doc.reload
      # raise "Document #{doc.cleansed_full_name}(#{doc.id}) failed to set #{attrib.to_s} to #{val} (errors: #{doc.errors.full_messages.join(', ')})" unless doc.read_attribute(attrib) == val
	  end
	
	  def save_description_reserved
	    return Document.find(:all, :conditions => ["description_reserved = ?", :yes]).map { |d| d.id }
	  end
	
	  def set_public_access(doc, bool)
	    set_attribute(doc, :public_access, bool)
	  end
	
	  def reverse_semantics(reserved)
	    say_with_time("Reversing semantics to public_access...") do
		    docs = Document.find(:all)
		    docs.each do
		      |d|
          raise "no public_access method for Document #{d.cleansed_full_name}(#{d.id})" unless d.respond_to?(:public_access=)
	        set_public_access(d, true)
		    end
	      reserved.each do
	        |d_id|
	        d = Document.find(d_id)
          say("set public access to false for #{d.cleansed_full_name} (#{d.id})")
          set_public_access(d, false)
	      end
	    end
	  end
	
	  def save_access_denied
	    return Document.find(:all, :conditions => ["public_access = ?", false]).map { |d| d.id }
	  end
	
	  def set_description_reserved(doc, val)
	    set_attribute(doc, :description_reserved, val)
	  end
	
	  def de_reverse_semantics(denied)
	    say_with_time("De-reversing semantics to description_reserved...") do
		    docs = Document.find(:all)
		    docs.each do
		      |d|
	        set_description_reserved(d, :no)
		    end
	      denied.each do
	        |d_id|
	        d = Document.find(d_id)
	        say("set description reserved to YES for #{d.cleansed_full_name} (#{d.id})")
          set_description_reserved(d, :yes)
	      end
	    end
	  end
	
	  def up
      saved_reserved = save_description_reserved
	    ActiveRecord::Base.transaction do
	      rename_column :documents, :description_reserved, :public_access
	      change_column :documents, :public_access, :boolean, :null => false, :default => true
      end
      #
      # the semantics need to be reversed because the two names mean the
      # opposite
      #
	    reverse_semantics(saved_reserved)
	  end
	
	  def down
	      saved_denied = save_access_denied
	    ActiveRecord::Base.transaction do
	      rename_column :documents, :public_access, :description_reserved
	      change_column :documents, :description_reserved, :enum, :limit => [:yes, :no], :default => :no
	    end
	    de_reverse_semantics(saved_denied)
	  end

  end

end
