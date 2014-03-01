#
# $Id: delete_subtree_test.rb 618 2012-09-23 04:40:09Z nicb $
#
require 'test/test_helper'

class DeleteSubtreeTest < ActionController::IntegrationTest

  fixtures  :users, :container_types, :documents

  def setup
    @u = User.authenticate('staffbob', 'testtest')
    @dl = DescriptionLevel.unita_documentaria
    @ct = ContainerType.find_by_container_type('Busta')
    assert @parent = documents(:fondo_privato)
		assert @parent_thread = [ documents(:fondo_GS), @parent ]
  end

  def test_delete_or_cancel
    go_to_login
    do_login
		assert csp = Folder.create(:name => 'P1',
		                    		:position => 1,
		                    		:parent => @parent,
		                    		:creator => @u, :last_modifier => @u,
		                    		:description_level_id => @dl.id, :container_type => @ct)
	  assert scsp = Folder.create(:name => 'SP1',
		                    		:parent => csp,
		                    		:creator => @u, :last_modifier => @u,
		                    		:description_level_id => @dl.id, :container_type => @ct)
		assert ds = Series.create(:name => 'D1',
		                    		:parent => scsp,
		                    		:creator => @u, :last_modifier => @u,
		                    		:description_level_id => @dl.id, :container_type => @ct)
		assert sp = Score.create(:name => 'S1',
		                    		:parent => csp,
		                    		:creator => @u, :last_modifier => @u,
		                    		:description_level_id => @dl.id, :container_type => @ct)
		@parent_thread.each do
			|p|
    	get(url_for(:controller => :doc, :action => :open), { :id => p.id })
    	assert_redirected_to :controller => 'doc', :action => 'show', :id => p.id.to_s
		end
    get(url_for(:controller => :doc, :action => :open), { :id => csp.id })
    assert_redirected_to :controller => 'doc', :action => 'show', :id => csp.id.to_s
    assert sb = SidebarTree.retrieve(session)
    assert_valid sb
    assert_equal sb.selected_item, csp.sidebar_tree_item(session)
    sel = [ csp.id.to_s ]
    post(url_for(:controller => :sidebar, :action => :delete_or_cancel), { :delete => 'confermo', :selection => sel })
    assert_redirected_to :controller => :doc, :action => :show, :id => @parent.id
    err = 0
    [csp, scsp, ds, sp].each do
      |d|
      begin
        d.reload
      rescue ActiveRecord::RecordNotFound
        err += 1
      end
    end
    assert_equal 4, err
  end

private

  def go_to_login
    get '/account/login'
    assert_response :success
    assert_template 'account/login'
  end

  def do_login
    post '/account/login', { :user => { :login => @u.login, :password => 'testtest' } }
    session['user'] = session.data['user']
    assert_redirected_to 'doc/front'
  end

end
