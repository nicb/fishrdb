#
# $Id: authority_record_display.rb 324 2009-03-06 04:26:22Z nicb $
#
#
# display collection of authority records
#
# require File.dirname(__FILE__) + '/authority_record_collection'

module DocumentParts

  module AuthorityRecordDisplay

	  def authority_record_collection
	    collection = [
	      AuthorityRecordCollection::PersonName.new(1, self),
	      AuthorityRecordCollection::CollectiveName.new(2, self),
	      AuthorityRecordCollection::SiteName.new(3, self),
	      AuthorityRecordCollection::ScoreTitle.new(4, self),
	    ]
	
	    return collection
	  end

  end

end
