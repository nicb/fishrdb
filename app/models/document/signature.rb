#
# $Id: signature.rb 619 2012-09-23 15:59:12Z nicb $
#
#

module DocumentParts

  module Signature

  require 'roman_numeral'

#	  def find_ancestors_up_to_series
#	    sidx = -1
#	    ancestors.each_with_index do
#	      |a, i|
#	      break if a.description_level.higher?(DescriptionLevel.serie)
#	      sidx = i
#	    end
#      if sidx >= 0
#	      result = ancestors[0..sidx].reverse
#      else
#        result = [ self ] # we're already higher than Series
#      end
#      return result
#	  end
	
	  def signature
			thread = ancestors.reverse
			thread << self
	    result = thread.map { |a| a.full_corda }.conditional_join('.')
      result =~ /^\.+$/ ? '' : result
	  end

    def find_series_or_higher_than_series
      result = nil
      ancs = ancestors.dup
      while !ancs.blank?
        result = ancs.shift
        break if result.description_level >= DescriptionLevel.serie
      end
      return result
    end

    def reference_series
      return self.find_series_or_higher_than_series
    end

    include ReferenceRootsHelper
	
	end

end
