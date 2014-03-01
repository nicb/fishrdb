#
# $Id: proxy.rb 447 2009-09-27 20:49:08Z nicb $
#

module DocumentParts

  module Proxy

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      #
      # This class method establishes a proxy reader method 
      # for the class that is associated by a has_one association
      #
      # For example:
      #
      # class BibliographicData < ActiveRecord::Base
      #   belongs_to :bibliographic_record
      # end
      #
      # class BibliographicRecord < Document
      #   has_one :bibliographic_data
      #   has_one_proxy_readers :bibliographic_data
      # end
      #
      # In this case, BibliographicRecord objects will have all the attribute
      # methods from BibliographicData as readers. If the class name cannot be
      # guessed from the first argument, it can be added as second (optional)
      # argument.
      #
      # NOTE: this DOES NOT YET WORK with the composed of methods, so this
      # needs to be improved
      #
      # Options:
      #
      # - :add => [ array of added proxy methods for composed_of methods ]
      # - :class_name => name of the class to be proxied
      #
      # class BibliographicRecord < Document
      #   has_one :bibliographic_data
      #   has_one_proxy_readers :bibliographic_data, :add => [ :publishing_date, :issue_year ]
      # end
      #
      #
      def has_one_proxy_readers(has_one_object, options = {})
        klass =  options.has_key?(:class_name) ? options[:class_name].constantize : has_one_object.to_s.camelize.constantize
        all_attributes = klass.column_names
        all_attributes << options[:add] if options.has_key?(:add) && options[:add].is_a?(Array)
        all_attributes.flatten!
        all_attributes.each do
          |n|
          module_eval("def #{n}(force_reload=false); return #{has_one_object.to_s}.#{n}; end")
        end
      end

    end

  end

end
