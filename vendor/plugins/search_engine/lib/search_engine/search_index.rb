#
# $Id: search_index.rb 543 2010-09-08 02:03:17Z nicb $
#
require 'yaml'

module SearchEngine

  class SearchIndex < ActiveRecord::Base

    belongs_to :record, :polymorphic => true
    has_many :search_index_class_references, :dependent => :destroy, :class_name => 'SearchEngine::SearchIndexClassReference'
    has_many :search_index_classes, :through => :search_index_class_references, :class_name => 'SearchEngine::SearchIndexClass'

    validates_presence_of :string, :field, :record_id
    validates_presence_of :reference_roots, :unless => :skip_reference_roots_validation, :on => :create
    validates_uniqueness_of :string, :scope => [:field, :record_id]

    def initialize(obj, parms = {})
        @object = obj
        return super(parms)
    end

    class <<self

      #
      # +index(obj, search_field, string)+
      # creates an index for a given string in a given field of a given object
      #
      # when we index, we need to make sure that the index is not already
      # there for another (possibly related) class (thus breaking the
      # uniqueness validation).
      #
      def index(obj, search_field, string)
        result = find_by_record_id_and_string_and_field(obj.id, string, search_field)
        unless result
	        parms =
	        {
	          :string => string,
	          :field => search_field.to_s,
	          :record_id => obj.id,
	          :reference_roots => obj.reference_roots,
	        }
	        result = create(obj, parms)
          raise(ActiveRecord::RecordInvalid, "Invalid SearchIndex(#{obj.id}, #{search_field}, #{string}) creation attempt (#{result.errors.full_messages.join(', ')})") unless result.valid?
        end
        result.link_to_class_names(obj.class)
        return result
      end

      def create(obj, parms)
        result = new(obj, parms)
        result.save
        return result
      end

    end

    def link_to_class_names(klass)
      sic = search_index_classes.find_by_class_name(klass.name)
      unless sic
	      ancs = klass.ancestors.map { |k| k if k.is_a?(Class) }.compact
	      last_class = ancs.index(ActiveRecord::Base)
	      last_class = ancs.index(Object) unless last_class
	      ancs.slice(0..last_class-1).each do      
	        |k|
	        link_to_class_name(k)
	      end
      end
    end

    #
    # +reference_roots+ returns a hash dump of reference root objects
    # (such as series document index for that specific object, etc.)
    # for each object returned by +related_records+. Basically, it 
    # deserializes the hash table from the db
    #
    # The hash table is in the following format
    # {
    #    doc1_id_string => reference_root1_id_string,
    #    doc2_id_string => reference_root2_id_string,
    #    ....
    # }
    #
    def reference_roots
      return YAML.load(read_attribute(:reference_roots))
    end

    def skip_reference_roots_validation
      return @object.class.skip_reference_roots_validation
    end

  private

    #
    # +reference_roots=+ will take a hash table and serialize it before saving
    # it into the database field
    # 
    def reference_roots=(hash_table)
      str = YAML.dump(hash_table)
      write_attribute(:reference_roots, str)
    end

    def link_to_class_name(klass)
      sic = SearchIndexClass.find_or_create_by_class_name(klass.name)
      begin
        sic.search_indices << self
      rescue ActiveRecord::RecordInvalid => msg
        logger.error(">>>> link_to_class_name(#{klass.name}): #{msg} for search index #{self.inspect} (referencing classes #{search_index_classes.map { |k| k.class_name }.join(', ')})")
      end
    end

  end

  class SearchIndexClass < ActiveRecord::Base

    has_many :search_index_class_references, :dependent => :destroy, :class_name => 'SearchEngine::SearchIndexClassReference'
    has_many :search_indices, :through => :search_index_class_references, :class_name => 'SearchEngine::SearchIndex'

    validates_presence_of :class_name
    validates_uniqueness_of :class_name

  end

  class SearchIndexClassReference < ActiveRecord::Base

    set_primary_key :search_index_id

    belongs_to :search_index
    belongs_to :search_index_class

    validates_presence_of :search_index_id, :search_index_class_id
    validates_uniqueness_of :search_index_id, :scope => :search_index_class_id

  end

end
