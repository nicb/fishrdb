#
# $Id: display_ar.rb 324 2009-03-06 04:26:22Z nicb $
#

module DocumentParts
  
  module DisplayAr

	  AR_FIELDS_TO_BE_DISPLAYED =
	  [
			SeparatorItem.new,
	
			DisplayArPersonNameItem.new(:display_person_names, "Nomi"),
			DisplayArItem.new(:display_collective_names, "Enti"),
			DisplayArItem.new(:display_site_names, "Luoghi"),
			DisplayArItem.new(:display_score_titles, "Titoli"),
	  ]

  end

end
