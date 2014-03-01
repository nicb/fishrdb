#
# $Id: score_tree_helper.rb 113 2007-12-18 18:50:11Z nicb $
#
# This is the function that builds the correct tree for the Score table
# it does it in three passes:
#
# 1) get all scores and builds a hash based on the 'contatore' field
# 2) reparents the children scores in the hash
# 3) delete the root copies of the reparented childrens from the hash
# 

module ScoreTreeHelper

	def build_tree(klass)
		tree = {}
		all_scores = klass.find(:all, :order => 'titolo_fascicolo')
		#
		# first convert into a flat tree
		#
		all_scores.map do
			|s|
			key = s.contatore.to_s
			tree[key] = s
		end
		#
		# then reparent
		#
		tree.each do
			|k, s|
			key = s.figlia_di
			if key and key.to_i != 0
				if tree.has_key?(key.to_s)
					tree[key.to_s].children = [] unless tree[key.to_s].children
					tree[key.to_s].children << s
				else
					raise "ATTENZIONE: NON E` STATA TROVATA LA SCHEDA GENITRICE #{s.figlia_di.to_s} (scheda figlia: #{s.contatore})"
				end
			end
		end
		#
		# then delete non-first-level records (those that have been reparented)
		#
		tree.each do
			|k, s|
			tree.delete(k) unless !s.figlia_di or s.figlia_di.to_i == 0
		end
	
		return tree
	end

end
