#
# $Id: add_fisold_reference.rb 179 2008-03-02 03:11:07Z nicb $
#
# This is a library of methods to add the 'contatore' reference count
# in scores.
# It uses the fisold_compare_lib library.
#
# 
# All of this is done by calling the 'add_fisold_reference' method.
#

module AddFisoldReference

  class MissingReference < Exception
  end

	require 'fisold_compare_lib'

  def self.update_fisold_score_reference(d, fods)
    fods.each do
      |fod|
      unless fods == 'none'
	      fodtn = FisoldReferenceDb.find(:first, :conditions => ["name = ?", fod.class.table_name])
	      already_set = Score.find(:first,
	        :conditions => ["fisold_reference_db_id = ? and fisold_reference_score = ?",
	        fodtn.id, fod.contatore])
	      unless already_set
	        d.update_attributes!('fisold_reference_db_id' => fodtn.id, 'fisold_reference_score' => fod.contatore)
	        $stderr.vputs("Score(#{d.id}).fisold_reference_score set to #{fod.contatore} (#{fodtn.name}): breaking the enclosing loop") unless ENV['VERBOSE'].blank?
	        break
	      end
      end
    end
  end
	
	def self.add_fisold_reference(subtree_root)
		args = [ ENV['RAILS_ENV'].blank? ? 'development' : ENV['RAILS_ENV'] ]
	
    open_comparison_dbs(args) do
      subtree_root = exact_compare_with_fisold(subtree_root) do
        |d, fods|
        update_fisold_score_reference(d, fods)
      end
    end
	end
end
