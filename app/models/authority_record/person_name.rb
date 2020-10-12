#
# $Id: person_name.rb 616 2012-06-21 11:47:43Z nicb $
#

class PersonName < AuthorityRecord
	has_many	:person_name_variants, :foreign_key => 'authority_record_id', :order => "name, first_name, pseudonym", :dependent => :destroy
  attr_readonly         :children_count
	public_class_method		:new, :create
  validates_uniqueness_of	:name, :scope => [:first_name, :pseudonym], :message => "&egrave; gi&agrave; stato inserito"
  validates_uniqueness_of	:first_name, :scope => [:name, :pseudonym], :message => "&egrave; gi&agrave; stato inserito"
  validates_uniqueness_of	:pseudonym, :scope => [:first_name, :name], :message => "&egrave; gi&agrave; stato inserito"
	validate :alternate_presences_of_name_first_name_or_pseudonym

  composed_of(:date, :class_name => 'ExtDate::Interval', :mapping =>
              [
                [:date_start, :to_date_from_s],
                [:date_end, :to_date_to_s],
                [:date_start_input_parameters, :dfips],
                [:date_end_input_parameters, :dtips],
                [:full_date_format, :intv_format],
                [:date_start_format, :from_format],
                [:date_end_format, :to_format],
              ], :allow_nil => true)

  allow_search_in [ :name, :first_name, :to_s, :full_name, :name_full, :pseudonym ]

public

  def to_s
    return [name, first_name, ornated_pseudonym].conditional_join(', ')
  end

  def full_name
    return [first_name, ornated_pseudonym, name].conditional_join(' ')
  end

  def name_full
    return [name, first_name, ornated_pseudonym].conditional_join(' ')
  end

private

	def ornated_pseudonym
		self.pseudonym && !self.pseudonym.empty? ? "(\"" + self.pseudonym + "\")" : ""
	end

  def match_attr?(property, other_attrs)
    result = false
    if self.send(property).blank?
      result = true if !other_attrs.has_key?(property) or other_attrs[property].blank?
    else
      result = other_attrs.has_key?(property) ? (other_attrs[property] == self.send(property)) : false
    end
    return result
  end

protected

  def allow_name_validation
		false
  end

  def alternate_presences_of_name_first_name_or_pseudonym
    errors.add("E` necessario inserire almeno il cognome, o il nome, o lo pseudonimo", '') if name.blank? and first_name.blank? and pseudonym.blank?
  end

  def match_first_name?(other_attrs)
    return match_attr?(:first_name, other_attrs)
  end

  def match_name?(other_attrs)
    return match_attr?(:name, other_attrs)
  end

  def match_pseudonym?(other_attrs)
    return match_attr?(:pseudonym, other_attrs)
  end

public

  def match?(other_attrs)
    return (match_first_name?(other_attrs) and match_name?(other_attrs) and match_pseudonym?(other_attrs))
  end

  def self.find_conditions(attrs)
		p = (attrs.has_key?(:pseudonym) && !attrs[:pseudonym].blank?) ? " and pseudonym = :pseudonym" : ""
    return "name = :name and first_name = :first_name#{p}", { :name => attrs[:name], :first_name => attrs[:first_name], :pseudonym => attrs[:pseudonym] }
  end

  def date_born
    return date.date_from.to_display
  end

  def date_died
    return date.date_to.to_display
  end

end

class PersonNameVariant < PersonName
	belongs_to	:accepted_form, :class_name => 'PersonName', :foreign_key => 'authority_record_id', :counter_cache => :children_count
	validates_presence_of	:authority_record_id

  include AuthorityRecordParts::VariantMethods

end

PersonName.class_eval do
  include AuthorityRecordParts::DisplayMethods::PersonNameParts
  include AuthorityRecordParts::AdjustDates::PersonNameParts
end
