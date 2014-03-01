#
# $Id: score.rb 561 2010-11-27 21:30:08Z nicb $
#

class Score < Document

	include Display::Model::DisplayHelper

  composed_of(:anno_composizione, :class_name => 'ExtDate::Year',
              :mapping => [ [:anno_composizione_score, :to_s] ]) { |d| ExtDate::Year.new(d)  }
  composed_of(:anno_edizione, :class_name => 'ExtDate::Year',
              :mapping => [ [:anno_edizione_score, :to_s] ]) { |d| ExtDate::Year.new(d)  }

protected

	FIELDS_TO_BE_DISPLAYED =
	[
		DisplayItem.new(:signature, 		"Segnatura"),
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
		DisplayItem.new(:public_access_display, "Consultabilit&agrave;"),
		DisplayItem.new(:public_visibility_display, "Visibilit&agrave;", :display_if_not_end_user),
		DisplayItem.new(:note,			"Note"),
		DisplayItem.new(:autore_versi_score,	"Autore Versi"),
		DisplayItem.new(:titolo_uniforme_score, "Titolo Uniforme"),
		DisplayItem.new(:dates_to_be_displayed, "Data"),
		DisplayItem.new(:display_container, "Contenitore"),
		SeparatorItem.new,
	]

public

  allow_search_in [ :autore_score, :raw_full_name, :organico_score, \
                  :anno_composizione_display, :edizione_score, :anno_edizione_display, \
                  :luogo_edizione_score, :trascrittore_score, :autore_versi_score, :dates_to_be_displayed, ]

  class << self

  protected
	
	  def get_composition_years(fparams, key)
	    return fparams.has_key?(key) ? ExtDate::Year.new(fparams.read_and_delete(key)) : nil
	  end
	
	  def get_anno_composizione_score(fparams)
	    return get_composition_years(fparams, :anno_composizione_score) 
	  end
	
	  def get_anno_edizione_score(fparams)
	    return get_composition_years(fparams, :anno_edizione_score) 
	  end
	
  public
	
	  def adjust_dates(fparams)
      [:anno_composizione, :anno_edizione].each do
        |k|
        method = 'get_' + k.to_s + '_score'
        fparams[k] = send(method, fparams) unless fparams.has_key?(k) && fparams[k].class == ExtDate::Year
      end
	    return super(fparams)
	  end
		#
		# special sort functions
		#
	
		def by_timeasc
			return 'anno_composizione_score ASC, anno_edizione_score ASC'
		end
	
		def by_timedesc
			return 'anno_composizione_score DESC, anno_edizione_score DESC'
		end
	
		def by_alpha
			return 'name, name_prefix, organico_score'
		end

  end # end of class methods

	def years_to_be_displayed
		result = []
		result << anno_composizione.to_display unless anno_composizione.to_display.blank?
		result << "[ed." + anno_edizione.to_display + "]" unless anno_edizione.to_display.blank?
		return result.conditional_join(' ')
	end

	def raw_name
		return read_attribute('name')
	end

	def raw_full_name
		return [name_prefix, raw_name].conditional_join(' ')
	end

  def full_name
    return (name == raw_name) ? raw_full_name : name
  end

  def is_a_unita_documentaria?
    result = false
	  result = (description_level == DescriptionLevel.unita_documentaria) if description_level
    return result
  end

  def parent_is_a_folder?
    return (parent.class == Folder)
  end

	def is_a_part?
	  result = is_a_unita_documentaria? && (parent && !parent_is_a_folder? &&
                                          (parent.raw_name == raw_name) &&
                                          (parent.autore_score == autore_score))
    return result
	end

	def note
		return convert_newlines_to_html('note')
	end

  #
  # sidebar display methods
  #

	def name # FIXME: Deprecated: will be removed later on
		result = raw_name

		if is_a_part? and !organico_score.blank?
			result = organico_score
		end

		return result
	end

  def sidebar_name
    result = full_name
    if (full_name == parent.full_name)
	  r_a = []
      r_a << forma_documento_score
      unless is_a_part?
		r_a << tipologia_documento_score
      end
      result = r_a.join(', ')
    end
    return result
  end

  def sidebar_tip
    result = [raw_full_name, full_name].uniq.conditional_join(' - ')
    added_info = [forma_documento_score, tipologia_documento_score].conditional_join(', ')
    result = result + ' (' + added_info + ')' unless added_info.blank?
    return result
  end

  def sidebar_dates
    return years_to_be_displayed
  end

  def anno_composizione_display
    return anno_composizione ? anno_composizione.to_display : ''
  end

  def anno_edizione_display
    return anno_edizione ? anno_edizione.to_display : ''
  end

end
