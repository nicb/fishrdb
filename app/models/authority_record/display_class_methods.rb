#
# $Id: display_class_methods.rb 498 2010-05-14 05:48:28Z nicb $
#

module AuthorityRecordParts

  module DisplayMethods

    module Base

	    def self.included(base)
	      base.extend ClassMethods
	    end
	
	    module ClassMethods
	
			private
			
			  def authority_file_name
			    return ''
			  end
			
			public
			
			  def accepted_form_term
			    return 'Forma accettata'
			  end
			
			  def accepted_form_terms
			    return 'Forme accettate'
			  end
			
			  def variant_form_term
			    return 'Forma variante'
			  end
			
			  def variant_form_terms
			    return 'Forme varianti'
			  end
			
			  def label
			    return name =~ /Variant$/ ? variant_form_term : accepted_form_term
			  end
			
			  def labels
			    return name =~ /Variant$/ ? variant_form_terms : accepted_form_terms
			  end
			
			  def div_name
			    return name =~ /Variant$/ ? 'variant' : 'accepted_form'
			  end
			
			  def find_conditions(attrs)
			    parsed_result = autocomplete_parse(attrs[:name])
			    result = ["name = :name", { :name => parsed_result[:name] }]
			    result = ["id = :id", {:id => parsed_result[:id]}] if parsed_result[:id]
			    return result
			  end
			
			  def master_class
			    return "#{self.name.sub(/Variant$/,'')}".constantize
			  end
			
			  def variant_form_class
			    return "#{master_class.name}Variant".constantize
			  end
			
			  def variant_form_method
			    return "#{master_class.name.underscore}_variants".intern
			  end
			
			  def reference_method
			    return "#{master_class.name.underscore}".intern
			  end
			
			  def create_method
			    return "create_#{master_class.name.underscore}_record".intern
			  end
			
			  def controller_show_set_method
			    return "show_#{master_class.name.underscore.pluralize}".intern
			  end
			
			protected
			
			  #
			  # this method returns the directory of the class-related views
			  # for offline CRUD. This is the default setting.
			  #
			  def view_dir
			    return 'ar/'
			  end
			
			  #
			  # this method returns the directory of the class-related views
			  # for inline CRUD (CRUD inside document edits). This is the default
			  # setting.
			  #
			  def inline_dir
			    return 'ar/'
			  end
			
			public
			
			  #
			  # the inline form appears in documents etc.
			  #
			  def inline_form
			    return inline_dir + 'doc_form'
			  end
			
			  #
			  # all other forms appear in the authority file section
			  #
			  def create_form
			    return inline_dir + 'form'
			  end
			
			  def edit_action
			    return view_dir + 'edit'
			  end
			
			  def variant_action
			    return view_dir + 'variant'
			  end
			
			  def show_action
			    return view_dir + 'show'
			  end
			
			  #
			  # autocomplete parse method
			  #
			
			  def autocomplete_parse(string)
			    return { :name => string, :id => nil }
			  end
			
			protected
			
			  def extended_autocomplete_parse(string)
			    result = AuthorityRecord.autocomplete_parse(string)
			    unless result[:name].blank?
			      parsed = result[:name].split('|',3)
			      result.update(:name => parsed[0].strip, :id => parsed[2].to_i) if parsed.size == 3
			    end
			    return result
			  end
	
	    end # end of class methods
		
    end

		module PersonNameParts
	
		  def self.included(base)
		    base.extend ClassMethods
		  end
	
	    module ClassMethods
		
			protected
			
			  def view_dir
			    return super + 'pn/'
			  end
			
			  def inline_dir
			    return super + 'pn/'
			  end
			
			public
			
			  def authority_file_name
			    return 'Nomi'
			  end
			
			  def autocomplete_parse(string)
			    return extended_autocomplete_parse(string)
			  end
	
	    end
		
		end
		
		module CollectiveNameParts
	
		  def self.included(base)
		    base.extend ClassMethods
		  end
		
	    module ClassMethods
	
			protected
			
			  def view_dir
			    return super + 'cn/'
			  end
			
			public
			
			  def authority_file_name
			    return 'Enti'
			  end
			
			  def autocomplete_parse(string)
			    return extended_autocomplete_parse(string)
			  end
	
	    end
			
		end
		
		module SiteNameParts
	
		  def self.included(base)
		    base.extend ClassMethods
		  end
		
	    module ClassMethods
	
			public
			
			  def authority_file_name
			    return 'Luoghi'
			  end
		
	    end
	
		end
		
		module ScoreTitleParts
	
		  def self.included(base)
		    base.extend ClassMethods
		  end
	
	    module ClassMethods
		
		  protected
		
			  def view_dir
			    return super + 'st/'
			  end
			
			public
			
			  def authority_file_name
			    return 'Titoli'
			  end
			
			  def extended_fields
			    return [
			      {:author => 'Autore:'},
			      {:transcriber => 'Trascrittore:'},
			      {:lyricist => 'Autore della Parte Letteraria:'},
			    ]
			  end
			
			  def autocomplete_parse(string)
			    return extended_autocomplete_parse(string)
			  end
	
	    end
		
		end

  end

end
