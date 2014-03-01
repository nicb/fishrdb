#
# $Id: cd_record.rb 632 2013-07-12 14:45:53Z nicb $
#
require 'fixnum_extensions'

class CdRecord < Document

  include DocumentParts::TwoPartDocument # this is a composed two-part document

  has_one  :cd_data, :dependent => :destroy
  has_one_proxy_readers :cd_data, :add => [:publishing_year, :booklet_authors]

  set_subkey :cd_data

  validates_associated :cd_data

protected

	FIELDS_TO_BE_DISPLAYED =
	[
		DisplayItem.new(:signature, "Segnatura"),
		DisplayItem.new(:full_corda, "Corda", :display_corda_condition),
		DisplayItem.new(:full_name, "Titolo"),
		DisplayItem.new(:record_label, "Etichetta"),
		DisplayItem.new(:catalog_number, "Etichetta"),
		DisplayItem.new(:publishing_year_display, "Data di Pubblicazione"),
		DisplayItem.new(:display_booklet_authors, "Libretto a cura di"),
		DisplayItem.new(:display_container, "Contenitore"),

		SeparatorItem.new,

		DisplayItem.new(:description, "Contenuto"),
		DisplayItem.new(:note,			"Note"),
		DisplayItem.new(:quantity,	"N.Copie"),
		DisplayItem.new(:public_access_display, "Consultabilit&agrave;"),
		DisplayItem.new(:public_visibility_display, "Visibilit&agrave;", :display_if_not_end_user),
		SeparatorItem.new,
	]

public

  allow_search_in [ :record_label, :catalog_number, :publishing_year_display, :display_booklet_authors, :quantity ]

  class <<self

    def cd_root
      fis = Folder.find_by_name_and_parent_id('Fondo Fondazione Isabella Scelsi', Document.fishrdb_root.id)
      return Folder.find_by_name_and_parent_id('CD e DVD', fis.id)
    end

    #
    # CRUD stuff
    #
  private

    def cd_extract_booklet_authors(fparams)
      return extract_has_many_items(fparams, :booklet_authors) do
        |args, c_args|
        Name.find_or_create(args, c_args) 
      end
    end

  public

    def cd_adjust_dates(fparams)
      year = nil
      year = fparams.read_and_delete_returning_empty_if_null(:publishing_year) \
        if fparams.has_key?(:publishing_year) && fparams[:publishing_year].class != ExtDate::Year
      fparams[:publishing_year] = ExtDate::Year.new(year)

      return fparams
    end

    def separate_all_has_many_associations(parms)
      parms = HashWithIndifferentAccess.new(parms)
      b_authors = cd_extract_booklet_authors(parms)
      result = yield(parms)
      if result && result.valid?
        result.send(subkey).clear_all_associations # removes all join records before re-adding them again
	      b_authors.each do
	        |ba|
	        result.booklet_authors << ba
	      end
      end
      return result
    end

    def create_from_form(parms = {}, session = nil)
      return separate_all_has_many_associations(parms) { |p| super(p, session) { |cd| cd_adjust_dates(cd) } }
    end

	  def edit_form
      return 'doc/cd_record/edit'
	  end
    
    #
    # sort functions
    #
  private

    def sort_by_time(doc)
      raise(ActiveRecord::RecordNotFound, "#{doc.inspect} record not found") unless doc && doc.valid?
      (res, culprit) = children_classes_ok?(doc)
      raise(ActiveRecord::ActiveRecordError, "#{doc.name} document has wrong children classes! (#{culprit})") unless doc.children(true).empty? || res
      return yield(doc.children(true))
    end

    def children_classes_ok?(doc)
      result = true
      culprit = self.name
      doc.children(true).each do
        |c|
        if c.class != self
          result = false
          culprit = c.class.name
          break
        end
      end
      return [ result, culprit ]
    end

  public

    def sort_by_timeasc(doc)
      return sort_by_time(doc) { |c| c.sort! { |a, b| a.safe_publishing_year <=> b.safe_publishing_year }}
    end


    def sort_by_timedesc(doc)
      return sort_by_time(doc) { |c| c.sort! { |a, b| b.safe_publishing_year <=> a.safe_publishing_year }}
    end

    def by_author
      return 'name'
    end

    def by_location
      return 'corda_alpha, corda'
    end

  end

  #
  # more CRUD stuff
  #

  def update_from_form(parms = {})
    k = self.class
    return k.separate_all_has_many_associations(parms) { |p| super(p) { |cd| k.cd_adjust_dates(cd) } }
  end

  #
  # display
  #

  def inspect
    sel_attrs = [:id, :parent_id, :position, :name, :description, :note, :creator_id, :last_modifier_id, :created_at,
        :updated_at, :container_type_id, :container_number, :corda, :consistenza, :public_access, :public_visibility]
    return two_part_inspect(sel_attrs, :cd_data)
  end

  def sidebar_tip
		fn = full_name.blank? ? nil : full_name + ', '
		rl = record_label.blank? ? nil : record_label + ' - '
		py = publishing_year.blank? ? nil : ' (' + publishing_year.year.to_s + ')'
		return [fn, rl, catalog_number, py].conditional_join('')
  end

  def sidebar_dates
    return publishing_year.year.to_s
  end

  def display_booklet_authors
    result = []
    booklet_authors.each { |ba| result << ba.full_name }
    return result.conditional_join(', ')
  end

  def publishing_year_display
    return publishing_year ? publishing_year.year.to_s : ''
  end

  def safe_publishing_year
    result = ExtDate::Year.new(0) # many years ago to be sure
    result = cd_data.publishing_year if cd_data && cd_data.publishing_year
    return result
  end

  def full_corda
	  cs = corda ? corda.to_i.to_sss : ''
	  ca = corda_alpha ? corda_alpha.to_s : ''
    return ca + cs
  end

  def corda_renumbering_scope
    return publishing_year ? publishing_year.year.to_i : 0
  end

  #
  # children class management
  #

	def allowed_children_classes
    result = CdTrackRecord
    result = specialized_allowed_classes('children') if read_attribute('allowed_children_classes')
    return result
	end

end
