#
# $Id: folder.rb 468 2009-10-17 02:21:36Z nicb $
#
class Folder < Document

private
	def	set_to_empty_container
		self.container_type_id = ContainerType.find(:first, :conditions => ["container_type = ''"]).id
	end

	before_create	:set_to_empty_container

protected

	FIELDS_TO_BE_DISPLAYED =
	[
		DisplayItem.new(:signature, "Segnatura"),
		DisplayItem.new(:full_corda, "Corda", :display_corda_condition),
		DisplayItem.new(:display_cleansed_full_name, "Titolo"),
		DisplayItem.new(:dates_to_be_displayed, "Data"),
		DisplayItem.new(:consistenza, "Consistenza"),
		DisplayItem.new(:display_container, "Contenitore"),
		DisplayItem.new(:description_level_described, "Livello di Descrizione"),

		SeparatorItem.new,

		DisplayItem.new(:description, "Contenuto"),
		DisplayItem.new(:public_access_display, "Consultabilit&agrave;"),
		DisplayItem.new(:public_visibility_display, "Visibilit&agrave;", :display_if_not_end_user),
		DisplayItem.new(:note,			"Note"),
		SeparatorItem.new,
	]

public

  class <<self

    def by_author
      return 'name'
    end

  end

private
  #
  # the folder default behaviour of allowed_children_classes is to return
  # almost the full range of available classes
  #
	def allowed_classes(column)
    return specialized_allowed_classes(column) do
      r = AVAILABLE_CLASSES.keys
      r.delete(CdTrackRecord)
      return r
    end
	end

public

	def allowed_children_classes
    return allowed_classes('children')
	end

	def allowed_sibling_classes
    return allowed_classes('sibling')
	end

end
