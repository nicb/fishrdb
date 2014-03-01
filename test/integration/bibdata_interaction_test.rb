#
# $Id: bibdata_interaction_test.rb 618 2012-09-23 04:40:09Z nicb $
#
require 'test/test_helper'

class BibdataInteractionTest < ActionController::IntegrationTest

  fixtures  :users, :container_types, :documents

  def setup
		assert @u_password = 'testtest'
    assert @u = User.authenticate('staffbob', @u_password)
    assert_valid @u
    assert @dl = DescriptionLevel.unita_documentaria
    assert @ct = ContainerType.find_by_container_type('Busta')
    assert_valid @ct
		assert @parent_thread = [ documents(:fondo_FIS), documents(:bibliography) ]
		@parent_thread.each { |p| assert_valid p }
  end

  def test_a_new_signup_login_and_navigation_experience
    logname = 'nuovo'
		passwd = 'nuova'
    new_signup(logname, passwd)
    do_login(logname, passwd)
    u = session['user']
		assert_nil parent = nil
		assert num_childs = 0
		@parent_thread.each do
			|p|
			parent = p
    	num_childs = parent.children(true).size
    	get '/doc/open', { :id => parent.id }
    	assert_redirected_to :action => :show, :id => parent.id
    	assert sb = SidebarTree.retrieve(session)
    	assert sbti = sb.sidebar_tree_items.find_by_document_id(parent.id)
    	assert_equal num_childs, sbti.children(true).size
		end
    #
    # now let's add a new bibliographic record
    #
    post '/doc/new_child/', { :id => parent.id, :position => 3, :classname => BibliographicRecord }
    assert_response :success
    #
    name = 'altro INTEGRATION TEST'
    post '/doc/create_or_update_form/', {"doc"=>{"num_items"=>"1", "name"=>name,
      "consistenza"=>"", "container_number"=>"", "position"=>"",
      "corda_alpha"=>"", "bibliographic_data"=>{"author_last_name"=>"", "number"=>"",
        "address"=>"", "translator_first_name"=>"", "end_page"=>"",
        "journal"=>"", "start_page"=>"", "editor_first_name"=>"",
        "language"=>"", "translator_last_name"=>"", "editor_last_name"=>"",
        "abstract"=>"", "volume"=>"", "publisher"=>"",
        "publishing_date"=>{"month"=>"",  "day"=>"", "year"=>""},
        "author_first_name"=>"", "issue_year"=>{"year"=>""}},
        "description_level_position"=>@dl.position, "corda"=>"",
        "creator_id"=>u.id, "container_type_id"=> @ct.id, "public_access"=>"true",
        "type"=>"BibliographicRecord", "last_modifier_id"=>u.id, "note" => "",
        "parent_id"=>parent.id, "name_prefix"=>"Un'",
        "public_visibility"=>"true"}, "action"=>"create_or_update_form",
        "controller"=>"doc", "update"=>" salva "}
    assert child = BibliographicRecord.find_by_name(name)
    assert_valid child
    assert_redirected_to 'action' => 'show', 'id' => child.id, 'page' => 1
    parent.children.reload
    assert_equal num_childs + 1, parent.children.size
    #
    # now let's update dates on it
    #
    iy = { 'year' => '1988' }
    pdate = { 'day' => '14', 'month' => '8', 'year' => '1956' }
    post '/doc/create_or_update_form/', {"doc"=>{"name"=>name,
          "consistenza"=>"", "container_number"=>"", "position"=>"1",
          "corda_alpha"=>"", "bibliographic_data"=>{"author_last_name"=>"",
          "number"=>"", "address"=>"", "translator_first_name"=>"",
          "end_page"=>"", "journal"=>"", "start_page"=>"",
          "editor_first_name"=>"", "language"=>"", "translator_last_name"=>"",
          "editor_last_name"=>"", "abstract"=>"", "volume"=>"",
          "publisher"=>"", "publishing_date"=> pdate,
          "author_first_name"=>"", "issue_year"=>iy},
          "description_level_position"=>@dl.position.to_s,
          "corda"=>"", "id"=>child.id.to_s, "creator_id"=>u.id.to_s,
          "container_type_id"=>@ct.id.to_s, "public_access"=>"true",
          "type"=>"BibliographicRecord", "last_modifier_id"=>u.id.to_s, "note"=>"",
          "parent_id"=>parent.id.to_s, "name_prefix"=>"Un'",
          "public_visibility"=>"true"}, "action"=>"create_or_update_form",
          "controller"=>"doc", "update"=>" salva "}
    assert_redirected_to 'action' => 'show', 'id' => child.id, 'page' => 1
    iyo = ExtDate::Year.new(iy)
    pdateo = ExtDate::Base.new(pdate, 'XXX', '%d/%m/%Y')
    assert_equal iyo.to_display, child.issue_year_display
    assert_equal pdateo.to_display, child.publishing_date_display

  end

private

  def go_to_login
    get '/account/login'
    assert_response :success
    assert_template 'account/login'
  end

  def do_login(login_name, passwd)
    post '/account/login', { :user => { :login => login_name, :password => passwd } }
    session['user'] = session.data['user']
    assert sb = SidebarTree.retrieve(session)
    assert_valid sb
    assert_redirected_to 'doc/front'
  end

  def new_signup(login_name, passwd)
    post '/account/signup', { :user => { :login => login_name,
      :name => 'Nuovo Nuovis', :email => 'new@nowhere.com', :password => passwd,
      :password_confirmation => passwd, :user_type => :staff } }
    assert_redirected_to 'account/login'
  end

end
