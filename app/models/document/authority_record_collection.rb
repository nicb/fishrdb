#
# $Id: authority_record_collection.rb 324 2009-03-06 04:26:22Z nicb $
#

module DocumentParts

  module AuthorityRecordCollection

		class Base
		  attr_reader :number, :doc
		
		  class PureVirtualCalled < StandardError
		  end
		
		  private_class_method :new
		
		  def initialize(n, doc)
		    @number = n
		    @doc = doc # might be null
		  end
		
		  def all_records
		    result = nil
		    result = @doc.send(self.class.method) if @doc
		    return result
		  end

      class <<self
		
			  def calc_valign
					return tag.size > 11  ? 'bottom' : 'top'
			  end
			
			  def arclass
    	    return name.sub(/DocumentParts::AuthorityRecordCollection::/,'').constantize
			  end
			
			  def tag
			    raise PureVirtualCalled, "#{name}.tag pure virtual method called"
			  end
			
			  def field
			    return arclass.name.underscore.intern
			  end
			
			  def subfield
			    return :name
			  end
			
			  def method
			     return field.to_s.pluralize.intern
			  end

      end
		
		end
		
		class PersonName < Base
		
		  public_class_method   :new
		
		  def self.tag
		    return 'Nomi'
		  end
		
		end
		
		class SiteName < Base
		
		  public_class_method   :new
		
		  def self.tag
		    return 'Luoghi'
		  end
		
		end
		
		class CollectiveName < Base
		
		  public_class_method   :new
		
		  def self.tag
		    return 'Enti'
		  end
		
		end
		
		class ScoreTitle < Base
		
		  public_class_method   :new
		
		  def self.tag
		    return 'Titoli'
		  end
		
		end

  end

end
