#
# $Id: index_system_test.rb 539 2010-09-05 15:53:58Z nicb $
#
require 'test/test_helper'
require 'search_engine'
require 'test/build_helper'
require 'test/utilities/index_rebuild'

class IndexSystemTest < ActiveSupport::TestCase

  include SearchEngine::Test::BuildHelper
  include SearchEngine::Test::Utilities::RandomString
  include SearchEngine::Test::Utilities::IndexRebuild

  class WrongMockObject < ActiveRecord::Base

    # no index system implementation, on purpose

  end

  def setup
    setup_db
    rebuild_search_index_if_needed(test_classes)
  end

  def teardown
    teardown_db
  end

  test "allow search in" do
    assert_equal [ :field_0, :field_1, :field_2, :field_3 ], MockObject1.search_engine_fields
    assert_equal [ :field_0, :field_1, :field_2, :field_3 ], SubMockObject.search_engine_fields
    assert_equal [ :field_0, :field_1, :field_2, :field_3, :one_more_field ], SubMockObjectWithMoreFields.search_engine_fields
    assert_equal [ :field_0, :field_4, :field_5, :field_6 ], MockObject2.search_engine_fields
    assert WrongMockObject.search_engine_fields.empty?
  end

  test "reference root" do
    assert moright1 = MockObject1.create(:field_0 => '0', :field_1 => 'a', :field_2 => 'b', :field_3 => 'c')
    assert moright1.valid?
    assert smoright1 = SubMockObject.create(:field_0 => '0', :field_1 => 'a', :field_2 => 'b', :field_3 => 'c')
    assert smoright1.valid?
    assert smoright2 = SubMockObjectWithMoreFields.create(:field_0 => '0', :field_1 => 'a', :field_2 => 'b', :field_3 => 'c', :one_more_field => 'z')
    assert smoright2.valid?
    assert moright2 = MockObject2.create(:field_0 => '0', :field_4 => 'd', :field_5 => 'e', :field_6 => 'f')
    assert moright2.valid?
    assert mowrong = WrongMockObject.create(:dummy => 'whatever')
    assert mowrong.valid?

    assert_equal({ moright1.id.to_s => moright1.id.to_s }, moright1.reference_roots)
    assert_equal({ smoright1.id.to_s => smoright1.id.to_s }, smoright1.reference_roots)
    assert_equal({ smoright2.id.to_s => smoright2.id.to_s }, smoright2.reference_roots)
    assert_equal({ moright2.id.to_s => moright2.id.to_s }, moright2.reference_roots)
    assert_raise(NoMethodError) { mowrong.reference_roots }
  end

  test "index number" do
    assert moright1 = MockObject1.create(:field_0 => '0', :field_1 => 'a', :field_2 => 'b', :field_3 => 'c')
    assert smoright1 = SubMockObject.create(:field_0 => '0', :field_1 => 'a', :field_2 => 'b', :field_3 => 'c')
    assert smoright2 = SubMockObjectWithMoreFields.create(:field_0 => '0', :field_1 => 'a', :field_2 => 'b', :field_3 => 'c', :one_more_field => 'z')
    assert moright2 = MockObject2.create(:field_0 => '0', :field_4 => 'd', :field_5 => 'e', :field_6 => 'f')
    assert mowrong = WrongMockObject.create(:dummy => 'whatever')

    [moright1, smoright1, smoright2, moright2].each do
      |mo|
      assert_equal mo.id, mo.related_records.first.id
    end
    assert_equal mowrong, mowrong.related_records.first
  end

end
