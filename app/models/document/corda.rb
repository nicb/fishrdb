#
# $Id: corda.rb 638 2013-09-11 07:27:21Z nicb $
#

module DocumentParts

  module Corda

	  def corda
	    result = read_attribute('corda')
	    if result && !result.blank? && result > 0 && result < 3999 && description_level == DescriptionLevel.serie
	      result = result.to_roman
	    end
	    return result
	  end

		def corda_for_edit_forms
			read_attribute('corda')
		end
	
	  def full_corda
	    cs = corda ? corda.to_s : ''
	    ca = corda_alpha ? corda_alpha.to_s : ''
	    return cs + ca
	  end

    def renumber_children_cordas(offset = 1)
      n = offset
	    children(true).each do
	      |d|
	      d.update_attributes!(:corda => n)
	      n += 1
	    end
    end

    def corda_renumbering_scope
      return data_dal ? data_dal.year.to_i : 0
    end

    def relative_renumber_children_cordas(offset = 1)
      last_par = n = nil
      c_array = children(true).sort { |a, b| a.corda_renumbering_scope <=> b.corda_renumbering_scope }
      c_array.each do
        |d|
        par = d.corda_renumbering_scope
        n = offset unless par == last_par
        d.update_attributes!(:corda => n)
        n += 1
        last_par = par
      end
    end

  end

end
