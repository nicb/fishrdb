#
# $Id: bibliographic_record.rb 630 2012-12-20 22:27:51Z nicb $
#

class BibliographicRecord < Document

  include DocumentParts::TwoPartDocument # this is a composed two-part document

  has_one :bibliographic_data, :dependent => :destroy
  has_one_proxy_readers :bibliographic_data, :add => [ :publishing_date, :issue_year ]

  set_subkey  :bibliographic_data

protected

	FIELDS_TO_BE_DISPLAYED =
	[
		DisplayItem.new(:signature, "Segnatura"),
		DisplayItem.new(:full_corda, 		"Corda", :display_corda_condition),
  	DisplayItem.new(:author_full_name, 		"Autore"),
		DisplayItem.new(:cleansed_full_name,			"Titolo"),
		DisplayItem.new(:journal,		"Periodico"),
		DisplayItem.new(:issue_year_display,		"Annata"),
  	DisplayItem.new(:volume,	"Volume"),
  	DisplayItem.new(:number,	"Numero"),
  	DisplayItem.new(:volume_title,	"Titolo del Volume"),
		DisplayItem.new(:address, "Citt&agrave;"),
		DisplayItem.new(:publisher, "Editore"),
		DisplayItem.new(:publishing_date_display, "Data"),
		DisplayItem.new(:academic_year, "Anno Accademico"),
  	DisplayItem.new(:compound_pages,	"Numeri di Pagina"),
		DisplayItem.new(:language, "Lingua"),
  	DisplayItem.new(:translator_full_name, "Traduttore"),
  	DisplayItem.new(:editor_full_name, "Curatore"),
		DisplayItem.new(:note,			"Note"),
		DisplayItem.new(:abstract,	"Abstract"),
		DisplayItem.new(:consistenza,	"Consistenza"),
		DisplayItem.new(:public_access_display, "Consultabilit&agrave;"),
		DisplayItem.new(:public_visibility_display, "Visibilit&agrave;", :display_if_not_end_user),
		DisplayItem.new(:display_container, "Contenitore"),
		SeparatorItem.new,
	]

public

  allow_search_in [ :author_full_name, \
    :cleansed_full_name, :journal, :issue_year_display, :volume, :number,
    :volume_title, :address, :publisher, :academic_year, :compound_pages,
    :language, :translator_full_name, :note, :abstract, :consistenza, ]

  class <<self

    def bd_adjust_dates(fparams_args)
      fparams = fparams_args.is_a?(Hash) ? HashWithIndifferentAccess.new(fparams_args) : fparams_args
      fparams[:issue_year] = ExtDate::Year.new(fparams.read_and_delete_returning_empty_if_null('issue_year')) if fparams.has_key?(:issue_year) && fparams[:issue_year].class != ExtDate::Year

      if fparams.has_key?(:publishing_date) && fparams[:publishing_date].class != ExtDate::Base
        p_date = fparams.read_and_delete_returning_empty_if_null(:publishing_date)
        fparams[:publishing_date] = ExtDate::Base.new(p_date,
                                                      ExtDate::Base.date_hash_to_ip_string(p_date),
                                                      ExtDate::Base.default_date_format_from_hash(p_date))
      end

      return fparams
    end
	  #
	  # CRUD stuff
	  #

    def create_from_form(parms = {}, session = nil)
      return super(parms, session) { |bd| bd_adjust_dates(bd) }
    end

	  def edit_form
      return 'doc/biblio/edit'
	  end

    #
    # sort functions
    #

    def sort_by_author(doc)
      childs = doc.children(true)
      result = childs.sort do
        |a, b|
				a_key = select_sort_key(a)
				b_key = select_sort_key(b)
				a_key <=> b_key
      end
      return result
    end

	private

		def select_sort_key(doc)
			res = doc.name
			if doc.is_a?(BibliographicRecord)
		    volstring = doc.volume.to_i == 0 ? doc.volume : "%04d" % doc.volume.to_i if doc.volume && !doc.volume.blank?
		    numstring = doc.number.to_i == 0 ? doc.number : "%04d" % doc.number.to_i if doc.number && !doc.number.blank?
			  datestring = doc.publishing_date && doc.publishing_date.is_a?(ExtDate::Base) ? doc.publishing_date.to_s : nil
			  res = [doc.author_last_name, doc.editor_last_name, doc.name, volstring, numstring, datestring].conditional_join(' ')
			end
			res
		end

  end

  #
  # more CRUD stuff
  #

  def update_from_form(parms)
    return super(parms) { |bd| self.class.bd_adjust_dates(bd) }
  end

  #
  # display functions
  #

protected

  def full_name_compound(first, last)
    return [ last, first ].conditional_join(', ')
  end

public

  def author_full_name
    return full_name_compound(author_first_name, author_last_name)
  end

  def translator_full_name
    return full_name_compound(translator_first_name, translator_last_name)
  end

  def editor_full_name
    return full_name_compound(editor_first_name, editor_last_name)
  end
  def compound_volume_number
    return [ volume, number ].conditional_join(':')
  end

  def compound_pages
    return [ start_page, end_page ].conditional_join('-')
  end

  #
  # The compound dates are broken: sometimes they are ok, sometimes they are
  # not and I can't pin down the problem (it has to do with composed_of
  # aggregations). While I investigate, the code is kludged
  #
public

  def proper_date_class(property, klass)
    result = nil
    if send(property)
	    case
	    when send(property).is_a?(klass) then result = send(property)
	    when send(property).is_a?(Date) then
        bd = BibliographicData.find_by_bibliographic_record_id(self.id)
        result = bd.send(property)
	    end
    else
      result = klass.new
    end
    return result
  end

private

  def date_kludge(property, klass)
    return proper_date_class(property, klass).to_display
  end

public

  def issue_year_display
    result = bibliographic_data.respond_to?(:issue_year) ?  issue_year.to_display : 'WRONG'
    return result
  end

  def publishing_date_display
    result = bibliographic_data.respond_to?(:publishing_date) ?  publishing_date.to_display : 'WRONG'
    return result
  end

  #
  # sidebar display methods
  #
  def sidebar_dates
    return publishing_date_display
  end

  def sidebar_name
    auth = author_full_name.blank? ? editor_full_name : author_full_name
    return [auth, full_name].conditional_join(', ')
  end

  def sidebar_tip
    return [sidebar_name, journal, compound_volume_number, compound_pages].conditional_join(', ')
  end

  def public_description_level_title
    return sidebar_name
  end
	
end
