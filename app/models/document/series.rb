#
# $Id: series.rb 541 2010-09-07 06:08:21Z nicb $
#

class Series < Document

	validates_presence_of :container_type

	belongs_to  	:container_type

protected

	FIELDS_TO_BE_DISPLAYED =
	[
		DisplayItem.new(:signature, "Segnatura"),
		DisplayItem.new(:full_corda, "Corda", :display_corda_condition),
		DisplayItem.new(:full_name, "Titolo"),
		DisplayItem.new(:dates_to_be_displayed, "Data"),
		DisplayItem.new(:consistenza, "Consistenza"),
		DisplayItem.new(:display_container, "Contenitore"),

		SeparatorItem.new,

		DisplayItem.new(:description, "Contenuto"),
		DisplayItem.new(:public_access_display, "Consultabilit&agrave;"),
		DisplayItem.new(:public_visibility_display, "Visibilit&agrave;", :display_if_not_end_user),
		DisplayItem.new(:note,			"Note"),
		SeparatorItem.new,
	]

public

  allow_search_in [ :dates_to_be_displayed, :consistenza ]

  class <<self

    def by_author
      return 'name'
    end

  end

end
