#
# $Id: 20100619033524_create_search_index_and_friends.rb 541 2010-09-07 06:08:21Z nicb $
#
require 'db/migrate/create_search_index_and_friends'

class CreateSearchIndexAndFriends < ActiveRecord::Migration

  class <<self

	  def up
      SearchEngine::CreateSearchIndexAndFriends.up
	  end
	
	  def down
      SearchEngine::CreateSearchIndexAndFriends.down
	  end

  end

end
