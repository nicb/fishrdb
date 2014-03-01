#
# $Id: multiple_users_test.rb 618 2012-09-23 04:40:09Z nicb $
#
require 'test/test_helper'
require 'session_user_helper'

class MultipleUsersTest < ActionController::IntegrationTest

  fixtures  :users, :container_types, :documents

  #
  # TODO: this needs to be expanded further, with concurrent CRUD actions etc.
  #
  def test_multiple_users
    staffbob, editbob = login(:staffbob), login(:editbob)

    staffbob.sidebar_toggle
    editbob.sidebar_toggle
  end

private

  module CustomAssertions

    include SessionUserHelper

    def sidebar_toggle
			assert parent_thread = [Document.root, documents(:fondo_GS), documents(:fondo_musicale)]
      assert parent = documents(:fondo_musicale)
			assert should_be = 0
			parent_thread.each { |p| assert should_be += p.children(true).size }
			assert should_be += 1 # 1 for the root node
      assert sb = SidebarTree.retrieve(session)
      assert_equal should_be, sb.sidebar_tree_items.size

      get(url_for(:controller => :doc, :action => :open), { :id => parent.id })
      assert_redirected_to :controller => 'doc', :action => 'show', :id => parent.id.to_s

      assert sb = SidebarTree.retrieve(session)
      assert_equal should_be, sb.sidebar_tree_items.size
    end

  end

  def login(who)
    assert parent_thread = [documents(:fondo_GS), documents(:fondo_musicale)]
		parent_thread.each { |parent| assert parent.valid?, "Invalid document #{parent.name} (#{parent.errors.full_messages.join(', ')})" }
    get '/account/login'
    assert_response :success
    assert_template 'account/login'

    result = open_session do
      |sess|
      sess.extend(CustomAssertions)
      me = users(who)
      sess.post '/account/login', { 'user' => { 'login' => me.login, 'password' => 'testtest' } }
      sess.assert_redirected_to :controller => :doc, :action => :front
			#
			# navigate to the proper place
			#
			parent_thread.each do
				|parent|
      	sess.get(url_for(:controller => :doc, :action => :open), { :id => parent.id })
      	sess.assert_redirected_to :controller => 'doc', :action => 'show', :id => parent.id.to_s
			end

      assert sb = SidebarTree.retrieve(sess.session)
      assert_equal 8, sb.sidebar_tree_items.size
    end
    return result
  end

end
