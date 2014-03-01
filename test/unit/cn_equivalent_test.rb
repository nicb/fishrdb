#
# $Id: cn_equivalent_test.rb 256 2008-07-23 06:06:42Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class CnEquivalentTest < ActiveSupport::TestCase

	fixtures	:users, :authority_records

  def setup
    assert @user     = User.authenticate('staffbob', 'testtest')
    assert @cnars    = CollectiveName.find(:all)
  end
  #
  def test_create_destroy
    assert cne = CnEquivalent.create(:name => 'test create and destroy',
                                     :creator => @user, :last_modifier => @user)
    assert cne.valid?
    cne.destroy
    assert cne.frozen?
  end

  def test_validations
    name = 'test validations'
    #
    # trying to create without a name should fail
    #
    cne = CnEquivalent.create(:creator => @user, :last_modifier => @user)
    assert !cne.valid?
    #
    # trying to create without a creator should fail
    #
    cne = CnEquivalent.create(:name => name, :last_modifier => @user)
    assert !cne.valid?
    #
    # trying to create without a last_modifier should fail
    #
    cne = CnEquivalent.create(:name => name, :creator => @user)
    assert !cne.valid?
    #
    # trying to create with an empty hash should fail
    #
    cne = CnEquivalent.create()
    assert !cne.valid?
    #
    # trying to create a duplicate of 'name' should fail
    #
    orig = CnEquivalent.create(:name => name, :creator => @user, :last_modifier => @user)
    assert orig.valid?
    duplicate = CnEquivalent.create(:name => name, :creator => @user, :last_modifier => @user)
    assert !duplicate.valid?
  end

  def add_cn
    @cnars.each do
      |cn|
      cn.add_to_collective_name_equivalent('test_addition', @user)
    end
    assert cneq = @cnars[0].cn_equivalent
    return cneq
  end

  def test_addition
    size = @cnars.size
    cneq = add_cn
    cneq.reload
    assert_equal cneq.collective_names.size, size, "(cneq.collective_names.size = #{cneq.collective_names.size}) != (@cnars.size = #{size})"
  end

  def test_removal
    size = @cnars.size
    cneq = add_cn
    cneq.reload
    cneq.remove_collective_name(cneq.collective_names[0], @user)
    cneq.reload
    assert_equal cneq.collective_names.size, size-1, "(cneq.collective_names.size = #{cneq.collective_names.size}) != (@cnars.size-1 = #{size-1})"
  end

end
