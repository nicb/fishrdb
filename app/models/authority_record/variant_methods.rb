#
# $Id: variant_methods.rb 517 2010-07-10 20:55:56Z nicb $
#

module AuthorityRecordParts

  module VariantMethods

    #
    # this method is required by the search_engine indexer
    #
    def related_records
      result = []
      result = accepted_form.related_records if accepted_form
      return result
    end

  end

end
