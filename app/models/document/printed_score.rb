#
# $Id: printed_score.rb 467 2009-10-16 00:45:26Z nicb $
#
class PrintedScore < Score

protected

	FIELDS_TO_BE_DISPLAYED =
	[
		DisplayItem.new(:signature, "Segnatura"),
		DisplayItem.new(:full_corda, 		"Corda", :display_corda_condition),
		DisplayItem.new(:autore_score, 		"Autore"),
		DisplayItem.new(:raw_full_name,			"Titolo"),
		DisplayItem.new(:organico_score,		"Organico"),
		DisplayItem.new(:misure_score,		"Misure"),
		DisplayItem.new(:consistenza,	"Consistenza"),
		DisplayItem.new(:forma_documento_score, "Forma del Documento"),
		DisplayItem.new(:tipologia_documento_score, "Tipologia del Documento"),
		DisplayItem.new(:anno_composizione_display, "Anno di Composizione"),
		DisplayItem.new(:edizione_score,		"Edizione"),
		DisplayItem.new(:anno_edizione_display, "Anno di Edizione"),
		DisplayItem.new(:luogo_edizione_score, "Luogo di Edizione"),
		DisplayItem.new(:trascrittore_score,	"Trascrittore"),
		DisplayItem.new(:description,	"Contenuto"),
		DisplayItem.new(:quantity,	"N.Copie"),
		DisplayItem.new(:public_access_display, "Consultabilit&agrave;"),
		DisplayItem.new(:public_visibility_display, "Visibilit&agrave;", :display_if_not_end_user),
		DisplayItem.new(:note,			"Note"),
		DisplayItem.new(:autore_versi_score,	"Autore Versi"),
		DisplayItem.new(:dates_to_be_displayed, "Data"),
		DisplayItem.new(:display_container, "Contenitore"),
		SeparatorItem.new,
	]

public

  class <<self

	  #
	  # CRUD stuff
	  #

	  def edit_form
      return 'doc/printed_score/edit'
	  end
  end

end
