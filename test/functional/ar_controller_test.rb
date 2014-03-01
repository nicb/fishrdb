#
# $Id: ar_controller_test.rb 616 2012-06-21 11:47:43Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

require 'authority_record'
require 'ar_controller'

class ArControllerTest < ActionController::TestCase

  fixtures  :users, :sessions, :documents, :authority_records

  def setup
    @controller = ArController.new
    assert @user = users(:staffbob)
    assert @anon_user = users(:anonymous)
		assert @admin_user = users(:bootstrap)
		assert @public_user = users(:bob)
    assert @s_1 = sessions(:one)
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
    #@user = User.authenticate('staffbob', 'testtest')
    @types = [PersonName, CollectiveName, SiteName, ScoreTitle]
  end

  #
  # we are going to use this in the next few tests
  #
  def add_a_new_person_name(last_name, first_name)
    post(:edit_from_form, {
      :class_name => 'PersonName',
      :authority_record => { :name => last_name, :first_name => first_name,
      :date_start => '', :date_end => '' },
      :commit => 'salva' }, { :user => @user })
  end

  def add_a_new_person_name_record_through_a_form_successefully
    add_a_new_person_name('Latilla', 'Gino')
    assert_redirected_to 'ar/' + @response.redirected_to[:action] + '/' + @response.redirected_to[:id].to_s
  end

  def test_add_the_same_person_twice_to_generate_failure
    #
    # first time successefully
    #
    add_a_new_person_name('Latilla', 'Gino')
    assert_redirected_to 'ar/' + @response.redirected_to[:action] + '/' + @response.redirected_to[:id].to_s
    #
    # second time failing (goes back to create template)
    #
    add_a_new_person_name('Latilla', 'Gino')
    assert_response :redirect
  end

  def test_pattern_add_success_add_failure_add_success_to_ensure_pre_emption_of_results
    #
    # first time successefully
    #
    add_a_new_person_name('Latilla', 'Gino')
    assert_redirected_to 'ar/' + @response.redirected_to[:action] + '/' + @response.redirected_to[:id].to_s
    #
    # second time failing (goes back to create template)
    #
    add_a_new_person_name('Latilla', 'Gino')
    assert_response :redirect
    #
    # third time, with a different name, should be successeful again
    #
    add_a_new_person_name('Pederobba', 'Quero-Vas')
    assert_redirected_to 'ar/' + @response.redirected_to[:action] + '/' + @response.redirected_to[:id].to_s
  end

  def test_show_with_all_types
    @types.each do
      |k|
      ars = k.all
      assert ars.size > 0, "#{k.name} is empty" # bark if class is empty
      ars.each do
        |ar|
        get :show, { :id => ar.id }, { :user => @user }
        assert_response :success
        assert_template 'show'
      end
    end
  end

	def test_security_on_ar_pages
		#
		# define user categories
		#
		assert lame_users = [ @anon_user, @public_user ]
		assert admin_users = [ @admin_user, @user ]
		#
		# try with an anonymous user first
		#
		lame_users.each do
			|lu|
			assert sess = @s_1.dup
	    @request.session.session_id = sess
	    @request.session['user'] = lu
			get :show_person_names, {}, { 'user' => lu, 'session_id' => @s_1.session_id }
			assert_redirected_to :controller => :account, :action => :login
		end
		#
		# now try with admin and/or staff users (should go through)
		#
		admin_users.each do
			|au|
			assert sess = @s_1.dup
			assert @request.session.session_id = sess
			assert @request.session['user'] = au
			get :show_person_names, {}, { 'user' => au, 'session_id' => sess.session_id }
    	assert_response :success
    	assert_template 'ar/show_set'
		end
	end

	def test_creating_ar_person_names
		assert sess = @s_1.dup
		assert @request.session.session_id = sess
		assert @request.session['user'] = @admin_user
		get :create, { :class_name => 'PersonName' }, { 'user' => @admin_user, 'session_id' => sess.session_id }
		assert_response :success
		assert_template 'ar/create'
		assert field_labels = [ 'Cognome:', 'Nome:', 'Pseudonimo:', 'Date:' ]
		field_labels.each do
			|fl|
			assert_select('th', fl)
		end
	end

end
