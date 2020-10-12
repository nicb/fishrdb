#
# $Id: manager_test.rb 539 2010-09-05 15:53:58Z nicb $
#
require 'test/test_helper'
require 'search_engine'
require 'test/build_helper'

class IndexSystemTest < ActiveSupport::TestCase

  include SearchEngine::Test::BuildHelper

  test "manager creation" do
    assert sem0 = SearchEngine::Manager.create
    assert sem1 = SearchEngine::Manager.create
    assert_equal sem0.object_id, sem1.object_id
  end

  test "searchable objects" do
    found = 0
    found_base = 0 # this must remain 0
    SearchEngine::Manager.searchable_objects.each do
      |sok|
      found += 1 if sok.name =~ /SearchEngine::Test::BuildHelper::/
      found_base += 1 if sok.name == 'SearchEngine::Test::BuildHelper::MockBase'
    end
    assert_equal 4, found # MockBase is excluded from indexing
    assert_equal 0, found_base
  end

end
