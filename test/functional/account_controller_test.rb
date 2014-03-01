#
# $Id: account_controller_test.rb 439 2009-09-17 08:11:02Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase

  fixtures :users

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
  return true
  end
  def test_login
    get :login
	  assert_response :success
  end

  def test_login_with_user
	  tester = User.authenticate('staffbob', 'testtest')
	  raise "User \"staffbob\" not found" unless tester
	  post :login, :user => { :login => tester.login, :password => 'testtest' }
	  assert_redirected_to "doc/front"
	  assert_equal tester.id, session[:user].id
  end
end
