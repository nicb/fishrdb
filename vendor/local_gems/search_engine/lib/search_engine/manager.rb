#
# $Id: manager.rb 539 2010-09-05 15:53:58Z nicb $
#
require 'search_engine/search_index'

module SearchEngine

  #
  # SearchEngine::Manager is a singleton class that handles all
  # SearchEngine-enabled objects
  #
  class Manager

    @@the_manager = nil

    private_class_method :new

    class <<self

      def create
        @@the_manager = new unless @@the_manager
        return @@the_manager
      end

      def add(klass)
        sem = create
        sem << klass
        return klass
      end

      def searchable_objects(filter = [])
        sem = create
        return sem.searchable_objects(filter)
      end

    end

    def initialize
      @searchable_objects = []
    end

    def searchable_objects(filter = [])
      result = []
      if filter.blank?
        result = @searchable_objects
      else
        @searchable_objects.each { |so| result << so if filter.include?(so) }
      end
      return result
    end

    def <<(obj)
      @searchable_objects << obj
      @searchable_objects.uniq!
    end
    #
    # +remove_searchable_object+: useful for testing purposes only
    #
    class NonExistentObjectRemovalAttempt < StandardError; end

    def remove_searchable_object(klass)
      res = @searchable_objects.delete(klass)
      raise(NonExistentObjectRemovalAttempt, "Attempting to remove non-searchable object #{klass.name}") unless res
      return res
    end

  end

end
