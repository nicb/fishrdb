#
# $Id: index_builder_test.rb 539 2010-09-05 15:53:58Z nicb $
#
require 'test/test_helper'
require 'search_engine'
require 'search_engine/index_builder'
require 'test/build_helper'
require 'test/utilities/index_rebuild'

class IndexBuilderTest < ActiveSupport::TestCase

  include SearchEngine::Test::BuildHelper
  include SearchEngine::Test::Utilities::RandomString
  include SearchEngine::Test::Utilities::IndexRebuild

  def setup
    @num = 100
    setup_db
  end

  def teardown
    teardown_db
  end

  test "build" do
    MockBase.delete_all
    clear_saved_strings
    created_strings = create_n_random_mocks(@num)
    n_indices = calc_number_of_indices
    assert_equal MockBase.all.size, @num
    assert ntoks = rebuild_search_index(test_classes)
    assert ntoks > 0
    assert_equal n_indices, ntoks
  end

  test "exclude_method option" do
    MockBase.delete_all
    clear_saved_strings
    previous_ntoks = rebuild_search_index(test_classes)
    assert mo1 = MockObject1.create(:field_0 => 'find field 0', :field_1 => 'find field 1', :field_2 => 'find field 2', :field_3 => 'find field 3')
    assert mo1.valid?
    assert invis = MockObject1.create(:field_0 => 'notfind field 0', :field_1 => 'notfind field 1', :field_2 => 'notfind field 2', :field_3 => 'notfind field 3', :visible => false)
    assert invis.valid?
    assert_equal 2, MockObject1.all.size
    new_ntoks = rebuild_search_index(test_classes)
    assert new_ntoks > 0
    #
    # only one new object should be indexed, through all the exposed fields
    #
    assert_equal previous_ntoks + MockObject1.search_engine_fields.size, new_ntoks
  end

  test "exclude_classes option" do
    MockBase.delete_all
    clear_saved_strings
    assert mo1 = MockObject1.create(:field_0 => 'find field 0', :field_1 => 'find field 1', :field_2 => 'find field 2', :field_3 => 'find field 3')
    assert mo2 = MockObject2.create(:field_0 => 'find field 0', :field_4 => 'find field 4', :field_5 => 'find field 5', :field_6 => 'find field 6')
    assert smo = SubMockObject.create(:field_0 => 'find field 0', :field_1 => 'find field 1', :field_2 => 'find field 2', :field_3 => 'find field 3')
    found_base = 0
    SearchEngine::Manager.searchable_objects.each do
      |so|
      found_base += 1 if so.name =~ /MockBase/
    end
    assert_equal 0, found_base # sem should not have MockBase which is excluded
  end

  #
  # NOTE: the +IndexBuilder::Builder.clean_slate+ is a private function which cannot be
  # accessed from outside the object.
  # Thus, in order to check that the cleaning functions well, we need to
  # - build once
  # - take note of the tokens built
  # - rebuild one more time
  # - check that the same number of tokens get built
  # - check that indexing starts from 1 and index is properly built
  #
  test "cleaning the slate" do
    MockBase.delete_all
    clear_saved_strings
    created_strings = create_n_random_mocks(@num)
    assert ntoks_before = rebuild_search_index(test_classes)
    assert nir_before = SearchEngine::SearchIndexClassReference.all.size
    #
    # we should re-index starting from scratch
    #
    assert ntoks_after = rebuild_search_index(test_classes)
    assert nir_after = SearchEngine::SearchIndexClassReference.all.size
    assert_equal ntoks_before, ntoks_after 
    assert_equal nir_before, nir_after
    assert_equal 1.upto(ntoks_after).map { |n| n }, SearchEngine::SearchIndex.all(:order => :id).map { |si| si.id }
  end

end
