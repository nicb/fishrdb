#
# $Id: cd_track_record.rb 632 2013-07-12 14:45:53Z nicb $
#

class CdTrackRecord < Document

  include DocumentParts::TwoPartDocument # this is a composed two-part document

  has_one  :cd_track, :dependent => :destroy
  has_one_proxy_readers :cd_track, :add => [:authors, :performers, :ensembles, :display_players]

  set_subkey :cd_track

  validates_associated :cd_track

protected

	FIELDS_TO_BE_DISPLAYED =
	[
    DisplayItem.new(:display_authors, "Autore/i"),
		DisplayItem.new(:full_title, "Titolo"),
		DisplayItem.new(:for, "Per"),
		DisplayItem.new(:duration, "Durata"),
    DisplayItem.new(:display_players, "Esecutori"),

		SeparatorItem.new,
    DisplayItem.new(:description, "Contenuto"),
    DisplayItem.new(:note, "Note"),
	]

public

  allow_search_in [ :display_authors, :full_title, :for, :duration, :display_players ]

  class << self

  private

    def extract_authors(fparams)
      return extract_has_many_items(fparams, :authors) do
        |args, cargs|
        Name.find_or_create(args, cargs)
      end
    end

    def extract_performers(fparams)
      return extract_has_many_items(fparams, :performers) do
        |args, cargs|
        n_args = args.read_and_delete(:name)
        i_args = args.read_and_delete(:instrument)
        n = Name.find_or_create(n_args, cargs)
        i = Instrument.find_or_create(i_args, cargs)
        args.update(:name_id => n.id, :instrument_id => i.id)
        Performer.find_or_create(args, cargs)
      end
    end

    def extract_ensembles(fparams)
      return extract_has_many_items(fparams, :ensembles) do
        |args, cargs|
        c = nil
        cond_args = args.read_and_delete(:conductor)
        c = Name.find_or_create(cond_args, cargs) if cond_args && !cond_args.blank?
        args.update(:conductor_id => c.id) if c && c.valid?
        Ensemble.find_or_create(args, cargs)
      end
    end

  public

    def adjust_duration(fparams)
      h = fparams.read_and_delete(:duration)
      fparams[:duration] = DateTime.new(0, 1, 1, h[:hour].to_i, h[:minute].to_i, h[:second].to_i) if h
      return fparams
    end

    def separate_all_has_many_associations(parms)
      parms = HashWithIndifferentAccess.new(parms)
      correlated = [ :authors, :performers, :ensembles ]
      local_authors = local_performers = local_ensembles = nil
      correlated.each do
        |c|
        cs = c.to_s
        eval("local_#{cs} = extract_#{cs}(parms)")
      end
      result = yield(parms)
      if result && result.valid?
        result.send(subkey).clear_all_associations # removes all join records before re-adding them again
	      correlated.each do
	        |c|
	        cs = c.to_s
          array = nil
          eval("array = local_#{cs}")
	        array.each do
	          |v|
	          result.send(c).send(:<<, v)
	        end
	      end
      end
      return result
    end

    def create_from_form(parms = {}, session = nil)
      return separate_all_has_many_associations(parms) { |p| super(p, session) { |cdt| adjust_duration(cdt) } }
    end

	  def edit_form
      return 'doc/cd_track_record/edit'
	  end
    
    #
    # sort functions
    #

    def by_position
      return 'position, ordinal'
    end

    def sort_by_author(doc)
      result = find_all_by_parent_id(doc.read_attribute(:id))
      result.sort! do
        |a, b|
        a_names = a.display_authors
        b_names = b.display_authors
        a_names <=> b_names
      end
      return result
    end

  end

  #
  # more CRUD stuff
  #

  def update_from_form(parms = {})
    k = self.class
    return k.separate_all_has_many_associations(parms) { |p| super(p) { |cdt| k.adjust_duration(cdt) } }
  end

  #
  # display functions
  #

  def full_title
    ord_s = ordinal ? sprintf("n.%2d", ordinal) : ''
    return name + ' ' + ord_s
  end

private

  def sub_display_authors(disp_method)
    result = ''
    if authors
	    if authors.size >= 2
	      result = authors[0..authors.size-2].map { |a| a.send(disp_method) }.join(', ')
	      result += ' e ' + authors.last.send(disp_method)
	    elsif authors.size == 1
	      result = authors.first.send(disp_method)
	    end
    end
    return result
  end

public

  def display_authors
    return sub_display_authors(:full_name)
  end

  def display_authors_last_names
    return sub_display_authors(:last_name)
  end

  def inspect
    sel_attrs = [:id, :parent_id, :position, :name, :description, :note, :creator_id, :last_modifier_id, :created_at,
        :updated_at, :container_type_id, :public_access, :public_visibility]
    return two_part_inspect(sel_attrs, :cd_track)
  end

  def sidebar_name
    return display_authors_last_names + ', ' + full_title
  end

  def sidebar_dates
    return duration
  end

  def sidebar_tip
		da = self.display_authors.blank? ? nil : self.display_authors + ', '
		ft = self.full_title.blank? ? nil : self.full_title + ' - '
		dp = self.display_players.blank? ? nil : self.display_players + ' - '
		dur = self.duration.blank? ? nil : '(' + self.duration + ')'
		return [da, ft, dp, dur].conditional_join('')
  end

  #
  # CdTrackRecord should not be able to have children under normal conditions
  #

	def allowed_children_classes
    return specialized_allowed_classes('children') { nil }
	end

end
