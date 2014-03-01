#
# $Id: description_level_test.rb 614 2012-05-11 17:25:14Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class DescriptionLevelTest < ActiveSupport::TestCase

  def setup
	@dl = DescriptionLevel.levels
  end

  def test_number_of_levels
    assert_equal DescriptionLevel.levels.size, @dl.size
  end

  def test_level_class_methods
    @dl.each do
      |dl|
      meth = dl.cleansed_level + '_level'
      assert dl.class.respond_to?(meth), "method #{dl.class.name}.#{meth} does not exist"
    end
  end

  def test_proxies
    @dl.each do
      |dl|
      meth = dl.cleansed_level
      assert dl.class.respond_to?(meth), "method #{dl.class.name}.#{meth} does not exist"
      assert_equal dl.id, dl.class.send(meth).id
    end
  end

  def test_level_class_methods
    @dl.each do
      |dl|
      meth = dl.cleansed_level + '_level'
      assert dl.class.respond_to?(meth), "method #{dl.class.name}.#{meth} does not exist"
    end
  end

  def test_proxies
    @dl.each do
      |dl|
      meth = dl.cleansed_level
      assert dl.class.respond_to?(meth), "method #{dl.class.name}.#{meth} does not exist"
      assert_equal dl.id, dl.class.send(meth).id
    end
  end

  def test_compares
    @dl.each do
      |dl|
      flag = :higher
      @dl.each do
        |other|
        if dl == other
          flag = :lower
          break
        end
        if flag == :higher
          assert dl > other, "Test failed for #{dl.level} > #{other.level}"
          assert dl.lower?(other), "Test failed for #{dl.level}.lower?(#{other.level})"
        elsif flag == :lower
          assert dl < other, "Test failed for #{dl.level} < #{other.level}"
          assert dl.higher?(other), "Test failed for #{dl.level}.higher?(#{other.level})"
        end
      end
    end
  end

  def test_compares_or_equal
    assert @dl[0] >= @dl[0]
    assert @dl[0] <= @dl[0]
    assert @dl[0] >= @dl[1]
    assert !(@dl[0] <= @dl[1])
    assert !(@dl[1] >= @dl[0])
  end

  def test_arithmetic
    dl = DescriptionLevel.fondo + 1
    assert dl == DescriptionLevel.sezione
    dl = dl - 1
    assert dl == DescriptionLevel.fondo
    dl = dl - 1
    assert dl == DescriptionLevel.fondo
    dl += 20
    assert dl == DescriptionLevel.unita_documentaria
    dl -= 100
    assert dl == DescriptionLevel.fondo
  end

end
