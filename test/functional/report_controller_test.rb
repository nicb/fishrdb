#
# $Id: report_controller_test.rb 445 2009-09-24 14:19:25Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class ReportControllerTest < ActionController::TestCase

  fixtures  :users, :sessions, :documents

  class ReportController; def rescue_action(e) raise e end; end

  def setup
    assert @user = User.authenticate('staffbob', 'testtest')
    assert @s_1 = sessions(:one)
    @request.session.session_id = @s_1.session_id
    @request.session['user'] = @user
    assert @sb = SidebarTree.retrieve(@s_1)
  end

  def test_report_generation
    tree_root = Document.fishrdb_root
    assert docs = Document.all
    docs.each do
      |d|
      unless d.no_children? || d == tree_root
        @sb.open_tree_up_to_document(d.id)
        assert sbti = d.sidebar_tree_item(@request.session)
        assert sbti.document.valid?
        get :list, { :id => sbti.document.id }
        assert_response :success
      end
    end
  end

end
