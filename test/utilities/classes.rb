#
# $Id: classes.rb 541 2010-09-07 06:08:21Z nicb $
#
require 'search_engine'

module Test

  module Utilities

    def document_classes
      return [ Folder, Series, Score, PrintedScore, BibliographicRecord, TapeRecord, CdRecord, CdTrackRecord ] # put all subclasses here
    end

    def searchable_classes
      return SearchEngine::SearchIndexClass.all.map { |sic| sic.class_name.constantize }
    end

    def editable_document_classes
      result = document_classes.dup
      result.delete(TapeRecord)
      return result
    end

  end

end
