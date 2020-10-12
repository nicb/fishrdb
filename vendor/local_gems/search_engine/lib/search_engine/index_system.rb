#
# $Id: index_system.rb 617 2012-07-15 16:30:06Z nicb $
#

module SearchEngine

  module IndexSystem

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def search_engine_fields
        @search_engine_fields ||= []
        @search_engine_fields += superclass.search_engine_fields if superclass.respond_to?(:search_engine_fields)
        @search_engine_fields.uniq!
        return @search_engine_fields
      end

      def search_engine_options
        @search_engine_options ||= {}
        @search_engine_options.update(superclass.search_engine_options) if superclass.respond_to?(:search_engine_options)
        return @search_engine_options
      end
      #
      # +allow_search_in+ takes an array of symbols which are basically indexed
      # methods from the object, and a hash of options. Options are:
      #
      # +:exclude_method+: if this method returns false, then the object is
      # excluded from indexing
      #
      # +:exclude_classes+: (array) the classes contained in this array are
      # excluded from insertion into the indexing manager 
      #
      def allow_search_in(fields, options = {})
        self.search_engine_fields.concat(fields)
        search_engine_options_update(options)
        search_engine_manager_subscribe
      end

      #
      # +inherited+ is a class method that gets called whenever the class
      # which includes this module gets subclassed. We use it here to
      # propagate the search fields and options to subclasses of searchable
      # classes. We have to avoid the first subclassing (the one from
      # ActiveRecord::Base, to be clear) to avoid subscribing classes without
      # the proper options setting
      #
      def inherited(subclass)
        subclass.search_engine_manager_subscribe unless subclass.search_engine_fields.blank?
        #
        # NOTE: if you don't call inherited's super method you break your
        # code totally and in subtle ways (for example: ActiveRecord::Base
        # fixtures won't load properly any longer, etc.) so: you better call
        # it.
        #
        return super(subclass)
      end

	    #
	    # some type of records may want to skip reference_roots validation
      # because they might not always have references (think of unconnected
      # AuthorityRecords, for example). In those cases, you may want to
      # override this method
	    #
	    def skip_reference_roots_validation
	      return false
	    end

    protected

      def search_engine_manager_subscribe
        SearchEngine::Manager.add(self) if included_in_indexing? && !subscribed?
      end

      def search_engine_options_update(options)
		    options.each do
		      |seo_key, seo_val|
          case seo_key
          when :exclude_method then
              search_engine_options.update(seo_key => seo_val)
          when :exclude_classes then
              search_engine_options[:exclude_classes] ||= []
              search_engine_options[:exclude_classes].concat([ seo_val ])
              search_engine_options[:exclude_classes].flatten!
          end
		    end
      end

      def included_in_indexing?
        result = false
        result = true unless search_engine_options.has_key?(:exclude_classes) && search_engine_options[:exclude_classes].index(self)
        return result
      end

      def subscribed?
        return SearchEngine::Manager.searchable_objects.index(self)
      end

    end

    class PureVirtualMethodCalled < StandardError; end

    #
    # counter NOTE: this should really be a virtual function raising an
    # exception, since this method should really be implemented in the host
    # class: otherwise we end up specializing this plugin to FisHRDB
    # documents, which is really not the case
    #
    # +reference_roots+ will return a hash of reference root object ids
    # (such as the series document index, etc.) for each document returned
    # by +related_records+
    #
    def reference_roots
      raise(PureVirtualMethodCalled, "pure virtual method 'reference_roots' called")
    end

    #
    # +related_records+ will in general return an array with self
    # however, this can be overridden to return the correct objects
    # searched (may be more than one in the case of authorities)
    #
    def related_records
      return [ self ]
    end

    #
    # +included_in_indexing?+ returns true if the object is included in
    # indexing, false otherwise
    #
    def included_in_indexing?
      result = true
      if !self.class.search_engine_options.blank? && self.class.search_engine_options.has_key?(:exclude_method)
        result = send(self.class.search_engine_options[:exclude_method])
      end
      return result
    end

  end

end
