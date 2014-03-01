#
# $Id: pview_controller_test.rb 619 2012-09-23 15:59:12Z nicb $
#
require 'test/test_helper'
require 'test/extensions/session'
require 'test/extensions/subtest'
require 'test/utilities/multiple_test_runs'
require 'test/functional/pview_controller_test/search_entries'

class PviewControllerTest < ActionController::TestCase

  fixtures  :all

  class PviewController; def rescue_action(e) raise e end; end

  include Test::Extensions
  include Test::Utilities::MultipleTestRuns

  number_of_runs(20)

  def setup
    assert @user = User.find_by_login('anonymous')
    assert @s_1 = sessions(:one)
    @request.session.session_id = @s_1.session_id
    @request.session['user'] = @user
		#
		# security check for all kinds of users
		#
    assert @staff_user = users(:staffbob)
    assert @anon_user = users(:anonymous)
		assert @admin_user = users(:bootstrap)
		assert @public_user = users(:bob)
		#
		# Roots of various kinds
		#
		assert @fondo_gs = documents(:fondo_GS)
		assert @fondo_gs.valid?
		assert @fondo_fis = documents(:fondo_FIS)
		assert @fondo_fis.valid?
  end

  def test_index
    get :index, nil

    assert_response :success
  end

  def test_some_random_page_shows
    #
    # pick some random 10 pages
    #
    assert pool = 10
		assert count = Document.count
    assert count > pool, "Document pool is too small (#{count}), aborting"
    assert pick_start = (rand * (count - pool)).to_i
    Document.all(:offset => pick_start, :limit => pool).each do
      |d|
      get :show, { :id => d.id }
      assert_response :success
      subtest_finished
    end
  end

  def pre_traverse_children(doc, &block)
    yield(doc)
    doc.children(true).each do
      |c|
      pre_traverse_children(c, &block)
    end
  end

  def post_traverse_children(doc, &block)
    doc.children(true).each do
      |c|
      post_traverse_children(c, &block)
    end
    yield(doc)
  end

  def test_sidebar_open
		[@fondo_gs, @fondo_fis].each do
			|froot|
	    sb = SidebarTree.retrieve(@request.session)
	    pre_traverse_children(froot) do
	      |d|
	      post :open, { :id => d.id }
	      assert_redirected_to :action => :show, :id => d.id
	      assert sbi = sb.sidebar_tree_items.find_by_document_id(d.id)
	      if sbi.document == Document.fishrdb_root
	        sbi.open # the root should be open by default, so an initial toggle
	                 # would close it, so we re-open it
	      end
	      assert sbi.open?
	      assert sbi.selected?
	      d.ancestors.reverse.each do
	        |a|
	        assert asbi = sb.sidebar_tree_items.find_by_document_id(a.id)
	        assert asbi.open?
	        assert !asbi.selected?
	      end
	    end
		end
  end

  def test_sidebar_toggle
		[@fondo_gs, @fondo_fis].each do
			|froot|
	    sb = SidebarTree.retrieve(@request.session)
	    pre_traverse_children(froot) do
	      |d|
	      # open
	      post :toggle, { :id => d.id }
	      assert_redirected_to :action => :show, :id => d.id
	      assert sbi = sb.sidebar_tree_items.find_by_document_id(d.id)
	      if sbi.document == Document.fishrdb_root
	        sbi.open # the root should be open by default, so an initial toggle
	                 # would close it, so we re-open it
	      end
	      assert sbi.open?
	      assert sbi.selected?
	      d.ancestors.reverse.each do
	        |a|
	        assert asbi = sb.sidebar_tree_items.find_by_document_id(a.id)
	        assert asbi.open?
	        assert !asbi.selected?
	      end
	    end
	    post_traverse_children(froot) do
	      |d|
	      # close
	      post :toggle, { :id => d.id, :open_tree => 'false' }
	      assert_redirected_to :action => :show, :id => d.id, :open_tree => 'false'
	      assert sbi = sb.sidebar_tree_items.find_by_document_id(d.id)
	      assert sbi.closed?
	      assert sbi.selected?
	    end
		end
  end

  def test_toggle_with_a_non_existing_document
    #
    # in order to test a non-existing document, we create a document, we pick
    # up its id and destroy it, so we make sure that it is a non-existing
    # document (any longer)
    #
    assert d = Folder.create(:name => 'Non-existing document', :parent => @fondo_GS,
                             :creator => @user, :last_modifier => @user,
                             :description_level_id => DescriptionLevel.serie.id,
                             :container_type => container_types(:scatolone))
    assert_valid d
    assert d_id = d.id
    assert d.destroy
    assert d.frozen?
    #
    # here d does not exist any longer
    #
    post :toggle, { :id => d_id }
    assert_redirected_to :action => :show
  end


  def test_show_with_a_non_existing_document
    #
    # in order to test a non-existing document, we create a document, we pick
    # up its id and destroy it, so we make sure that it is a non-existing
    # document (any longer)
    #
    assert d = Folder.create(:name => 'Non-existing document', :parent => @fondo_GS,
                             :creator => @user, :last_modifier => @user,
                             :description_level_id => DescriptionLevel.serie.id,
                             :container_type => container_types(:scatolone))
    assert_valid d
    assert d_id = d.id
    assert d.destroy
    assert d.frozen?
    #
    # here d does not exist any longer
    #
    get :show, { :id => d_id }
    assert_response :success
    assert_template 'pview/show'
    assert_select('div.errorExplanation')
  end

  def test_a_tape_record_without_images
    #
    # let's create a fake tape record which won't have any images
    # it should show just the same without crashing ([ticket:216 #216])
    #
    assert tr = TapeRecord.create_from_form({ :name => 'Tape without images', :parent => @fondo_fis,
                                  :creator => @user, :last_modifier => @user,
                                  :description_level_position => DescriptionLevel.serie.position,
                                  :container_type => container_types(:aa_busta), :tape_data => { :tag => 'NMGSXXXX-XXX' } }, @s_1)
    assert_valid tr
    #
    # let's try to show it
    #
    get :show, { :id => tr.id }
    assert_response :success
    assert_template 'pview/show'
  end

  #
  # SEARCH TESTS
  #
  #
  # PLEASE NOTE: the use of the +wrapped_post+ private method is *MANDATORY*
  # to propagate properly @response and elements
  #
  def test_generic_search
    SearchEntry.common_search do
      |se, sel|
      wrapped_post(:generic_search, { "term" => se.search_term }, sel)
    end
  end

  def test_tape_record_search
    TapeRecordSearchEntry.common_search do
      |se, sel|
      wrapped_post(:tape_search, { "term" => se.search_term }, sel)
    end
  end

  def test_score_search
    ScoreSearchEntry.common_search do
      |se, sel|
      wrapped_post(:score_search, { "title" => se.search_term, "author" => se.author }, sel)
    end
  end

  def test_archive_search
    ArchiveSearchEntry.common_search do
      |se, sel|
      st = { 'term' => se.search_term }
      st.update(se.series_terms)
      wrapped_post(:archive_search, st, sel)
    end
  end

	#
	# security tests: viewing pages should be available to all users
	#
	def test_security_on_editing_pages
		#
		# define user categories
		#
		assert all_users = [ @anon_user, @public_user, @admin_user, @user ]
		#
		# try with all users
		#
		assert doc = documents(:Parte__0904)
		all_users.each do
			|au|
			assert sess = @s_1.dup
			assert @request.session.session_id = sess
			assert @request.session['user'] = au
			get :show, { :id => doc.id }, { 'user' => au, 'session_id' => sess.session_id }
    	assert_response :success
    	assert_template 'pview/show'
		end
	end

	#
	# check that the corda appears in the final documents also in pview
	#
	def test_corda_display_in_pview_mode
		assert doc = documents(:carte_personali_e_familiari)
		assert corda_should_be = doc.full_corda.to_s
		assert doc.valid?
		assert sess = @s_1.dup
		get :show, { :id => doc.id }, { :user => @user, 'session_id' => sess.session_id }
   	assert_response :success
   	assert_template 'pview/show'
		assert_select('td.sidebar_list_corda', { :text => corda_should_be })
	end

private

  class NullResponse < StandardError; end

  def wrapped_post(method, term, sel)
    @response = post(method, { "search" => term })
    @request = @response.request
    assert_response :success
    result = css_select(sel)
    raise(NullResponse, "Null response from post(:#{method}, { 'search' => #{term.inspect} })") if !result.is_a?(Array) || result.empty?
    return result
  end

end
