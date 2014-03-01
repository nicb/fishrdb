#
# $Id: authority_record_management.rb 324 2009-03-06 04:26:22Z nicb $
#
# authority record management
#
# checks wether the authority record is not already linked to the document,
# then creates a new authority record (if it does not exist already,
# and creates an ard reference between the document and the record.
# returns the authority record
# 

module DocumentParts

  module AuthorityRecordManagement
    
  public

    def self.included(base)
      base.extend ClassMethods
    end
	
	private

    module ClassMethods

		  def ar_class_name(ar)
		    return "#{ar.class.name.sub(/Variant$/,'')}" # just the parent class name
		  end
		
		  def ard_class(ar)
		    return "#{ar_class_name(ar)}ArdReference".constantize
		  end

    end
	
	  def lookup_variant_authority_record(ar, attrs)
	    result = false
	    varmeth = "#{self.class.ar_class_name(ar).underscore}_variants"
	    ar.send(varmeth).each do
	      |darvar|
	      if darvar.match?(attrs)
	        result = darvar
	        break
	      end
	    end
	    return result
	  end
	
	  def lookup_authority_record(arclass, attrs)
	    ar = false
	    if attrs[:id]
	      ar = arclass.find(attrs[:id])
	    else
		    armeth = arclass.name.underscore.pluralize
		    self.send(armeth).each do
		      |dar|
		      ar = lookup_variant_authority_record(dar, attrs)
		      if !ar and dar.match?(attrs)
		        ar = dar
		        break
		      end
		    end
	    end
	    return ar
	  end
	
	  def find_ard_conditions(ar)
	    return ["document_id = ? and authority_record_id = ?",
	      self.read_attribute('id'), ar.read_attribute('id') ]
	  end
	
	  def find_ard_from_ar(ar)
	    return self.class.ard_class(ar).find(:first, :conditions => find_ard_conditions(ar))
	  end
	
	  def create_authority_record(klass, user, attrs)
	    #
	    # check if the authority record is not already in there
	    #
	    ar = lookup_authority_record(klass, attrs)
	
	    unless ar
	      conds = klass.find_conditions(attrs)
	      ar = klass.find(:first, :conditions => conds)
	      unless ar
	        attrs[:creator] = attrs[:last_modifier] = user
	        ar = klass.create(attrs)
	      end
	    else
	      ar = ar.accepted_form if ar.variant?
	    end
	    ar = ar.accepted_form # make sure we get the accepted form
	    ard = bind_authority_record(user, ar)
	
	    return ar
	  end
	
	public
	
	  def bind_authority_record(user, ar)
	    ard = find_ard_from_ar(ar)
	    unless ard
	      ardsym = "#{self.class.ar_class_name(ar).underscore}".intern # ex.: :person_name
	      ard = self.class.ard_class(ar).create(:document => self, ardsym => ar,
	                                            :creator_id => user.id, :last_modifier_id => user.id)
	    end
	    return ard
	  end
	
	  def create_person_name_record(user, attrs) # attrs is a hash that must have at least the :name property
	    return create_authority_record(PersonName, user, attrs)
	  end
	
	  def create_collective_name_record(user, attrs) # attrs is a hash that must have at least the :name property
	    return create_authority_record(CollectiveName, user, attrs)
	  end
	
	  def create_site_name_record(user, attrs) # attrs is a hash that must have at least the :name property
	    return create_authority_record(SiteName, user, attrs)
	  end
	
	  def create_score_title_record(user, attrs) # attrs is a hash that must have at least the :name property
	    return create_authority_record(ScoreTitle, user, attrs)
	  end
	
	  def detach_authority_record(ar)
	    self.class.ard_class(ar).delete_all(find_ard_conditions(ar))
	  end
	
	  def create_variant_authority_record(ref, user, attrs)
	    ar = lookup_authority_record(ref.class, attrs)
	
	    unless ar
	      conds = ref.class.find_conditions(attrs)
	      ar = ref.class.find(:first, :conditions => conds)
	      unless ar
	        varclass = "#{ref.class.name}Variant".constantize
	        ar = varclass.find(:first, :conditions => conds)
	      end
	      unless ar
	        ar = ref.create_variant_authority_record(user, attrs)
	      end
	    end
	    ard = bind_authority_record(user, ar)
	
	    return ar
	  end

  end

end
