#
# $Id: search_test.rb 539 2010-09-05 15:53:58Z nicb $
#
require 'test/test_helper'
require 'test/build_helper'
require 'search_engine'
require 'search_engine/index_builder'
require 'search_engine/string_extensions'

class SearchTest < ActiveSupport::TestCase

  include SearchEngine::Test::BuildHelper

  def setup
    setup_db
    @num_objects =  100
    @num_searches =  50
    create_environment
  end

  def teardown
    teardown_db
  end

  test "single search" do
    common_search do
      |n, s_v|
      indices = SearchEngine::Search.search(s_v.string)
      found = count_results(s_v, indices)
      assert found > 0, "Search n.#{n} failed: \"#{s_v.string}\" (on mock n. #{s_v.id} -- indexed as #{MockBase.find(s_v.id).inspect}) not found"
      Rails::logger.warn(">>>> single SearchEngine::Search.search: found #{found} results instead of just 1") if found > 1
    end
  end

  test "specialized class search" do
    common_search do
      |n, sv|
      klass = sv.class_name.constantize
      ancs = klass.ancestors.map { |k| k if k.class == Class }.compact
      ar_index = ancs.index(ActiveRecord::Base)
      ar_index = ancs.index(Object) unless ar_index
      klass_and_ancestors = ancs.slice(0..ar_index-1)
      klass_and_ancestors.each do
        |kl|
        indices = kl.search(sv.string)
        found = count_results(sv, indices)
        assert found > 0, "#{sv.class_name}.search n.#{n} failed: \"#{sv.string}\" (on #{sv.class_name},#{sv.field} id #{sv.id} not found"
        Rails::logger.warn(">>>> #{kl}.search: found #{found} results instead of just 1") if found > 1
      end
    end
  end

  test "search with a null string (only extra conditions)" do
    common_search do
      |n, sv|
      klass = sv.class_name.constantize
      sterm = '%' + sv.string + '%'
      oc = FindOptionHelper::Condition.new("string like", sterm)
      indices_generic = SearchEngine::Search.search(nil, [oc])
      indices_special = klass.search(nil, [oc])
      found_generic = count_results(sv, indices_generic)
      found_special = count_results(sv, indices_special)
      assert found_generic > 0, "SearchEngine::Search.search n.#{n} failed: \"#{sv.string}\" (on #{sv.class_name}, #{sv.field} id #{sv.id} not found)"
      assert found_special > 0, "#{sv.class_name}.search n.#{n} failed: \"#{sv.string}\" (on #{sv.class_name}, #{sv.field} id #{sv.id} not found)"
      Rails::logger.warn(">>>> SearchEngine::Search.search: found #{found_generic} results instead of just 1") if found_generic > 1
      Rails::logger.warn(">>>> #{klass}.search: found #{found_special} results instead of just 1") if found_special > 1
    end
  end

  test "search with no arguments" do
    common_search do
      |n, sv|
      klass = sv.class_name.constantize
      indices_generic = SearchEngine::Search.search(nil)
      indices_special = klass.search(nil)
      found_generic = count_results(sv, indices_generic)
      found_special = count_results(sv, indices_special)
      assert_equal 0, found_generic, "SearchEngine::Search.search n.#{n}"
      assert_equal 0, found_special, "#{sv.class_name}.search n.#{n}"
    end
  end

  test "search with empty arguments" do
    common_search do
      |n, sv|
      klass = sv.class_name.constantize
      indices_generic = SearchEngine::Search.search('')
      indices_special = klass.search('')
      found_generic = count_results(sv, indices_generic)
      found_special = count_results(sv, indices_special)
      assert_equal 0, found_generic, "SearchEngine::Search.search n.#{n}"
      assert_equal 0, found_special, "#{sv.class_name}.search n.#{n}"
    end
  end

private

  def count_results(sv, indices)
    found = 0
    indices.each { |i| found += 1 if sv.id == i.record_id }
    return found
  end

  def common_search
    1.upto(@num_searches) do
      |n|
      sv = build_single_random_search_string_verifier
      next if sv.string.search_engine_cleanse.empty? # do not search empty strings, which will return null
      yield(n, sv)
    end
  end

  def create_environment
    num = @num_objects
    n_created_strings = create_n_random_mocks(num)
    n_indices = calc_number_of_indices
    assert_equal MockBase.all.size, num
    ntoks = SearchEngine::IndexBuilder::Builder.build(self.test_classes)
    assert ntoks > 0
    assert_equal n_indices, ntoks
  end

  def build_single_random_search_string_verifier
    s_v = choose_string_verifier.clone
    sz = s_v.string.size
    sch = (rand() * sz * 0.2).round
    ext = (rand() * (sz - sch - 1)).round
    s_v.string = s_v.string.slice(sch..sch+ext)
    return s_v
  end

  def choose_string_verifier
    rn = (rand() * (saved_strings.size-1)).round
    return saved_strings[rn]
  end

end
