#
# $Id: printed_score_test.rb 454 2009-10-02 20:51:29Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class PrintedScoreTest < ActiveSupport::TestCase

  fixtures :container_types, :users, :sessions, :documents

  def setup
    assert @ct = container_types(:aa_busta)
    assert @dl_pos = DescriptionLevel.unita_documentaria.position
    assert @user = users(:bob)
    assert @s_1 = sessions(:one)
    assert @parent = documents(:pscores)
    assert @common_args = { :parent => @parent, :container_type => @ct,
      :name => 'Test Printed Score',
      :description_level_position => @dl_pos, :creator => @user,
      :last_modifier => @user }
  end

  def test_create_and_destroy
    #
    # w/o quantity
    #
    assert ps = PrintedScore.create_from_form(@common_args, @s_1)
    assert ps.valid?
    assert ps.reload
    assert_equal 1, ps.quantity
    #
    assert ps.destroy
    assert ps.frozen?
    #
    # now w quantity
    #
    qt = 10
    args = @common_args.dup
    args.update(:quantity => qt)
    assert ps = PrintedScore.create_from_form(args, @s_1)
    assert ps.valid?
    assert ps.reload
    assert_equal qt, ps.quantity
    #
    assert ps.destroy
    assert ps.frozen?
  end
  
end
