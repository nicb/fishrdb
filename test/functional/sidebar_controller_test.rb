#
# $Id: sidebar_controller_test.rb 618 2012-09-23 04:40:09Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../utilities/string'
require File.dirname(__FILE__) + '/../extensions/session'

class SidebarControllerTest < ActionController::TestCase

  fixtures  :all

  class SidebarController; def rescue_action(e) raise e end; end

  def setup
    assert @ct = container_types(:aa_busta)
    assert_valid @ct
    assert @dl_pos = DescriptionLevel.unita_documentaria.position
    assert @user = users(:staffbob)
    assert_valid @user
    assert @fis_parent = documents(:fondo_GS)
    assert_valid @fis_parent
    assert @s_1 = sessions(:one)
    assert_valid @s_1
    assert @name = names(:gs)
    assert_valid @name
    @request.session.session_id = @s_1.session_id
    @request.session['user'] = @user
    @request.session['session_id'] = @s_1.session_id
  end

  #
  # this was written to correct [ticket:219 #219]
  #
  def test_cut_pasting_a_document_onto_itself
    leafsize = 20
    parent = create_folder(@fis_parent, 'parent')
    mass_generate_documents(parent, leafsize)
    
    child_idx = 11
    child = parent.children[child_idx]
    #
    # make sure the SidebarTreeItem exists
    #
    assert sb = SidebarTree.retrieve(@request.session)
    assert_valid sb
    sb.open_tree_up_to_document(child.id)
    #
    # check that even a single looping element works
    #
    clip_copy = generate_clipboard_copy_hash(parent, [ child_idx ])
    post :manipulate_selection, { 'copied_to_clipboard' => clip_copy, 'copy' => 'taglia selezionati' }
    assert_redirected_to :controller => :doc, :action => :show, :id => child.id

    get :paste_child_below_here, { :id => child.id }
    assert_response :success
    assert_template 'sidebar/paste_confirmation'

    post :paste_or_cancel, { 'paste' => 'confermo', 'next_action' => 'paste_child', 'selection' => [ child.id.to_s ], 'id' => child.id.to_s }
    assert_redirected_to :controller => :doc, :action => :show, :id => child.id
    assert_equal parent.id, child.parent.id # re-parenting was not performed
  end

  def test_cut_pasting_a_document_onto_itself_among_many_documents
    leafsize = 20
    #
    # make sure the SidebarTreeItem exists
    #
    assert sb = SidebarTree.retrieve(@request.session)
    assert_valid sb
    #
    # check that multiple elements will correctly skip the offending looping one 
    #
    to_be_copied = []
    0.upto(leafsize-1) do
      |idx|
      sel = []
      assert parent = create_folder(@fis_parent, 'another parent')
      assert_valid parent
      mass_generate_documents(parent, leafsize)
      #
      assert child = parent.children(true)[idx], "parent.children[#{idx}] does not exist"
      sb.open_tree_up_to_document(child.id)
      to_be_copied << idx
      clip_copy = generate_clipboard_copy_hash(parent, to_be_copied)
      clip_copy.each { |k, v| sel << k if v == 'yes' }
      post :manipulate_selection, { 'copied_to_clipboard' => clip_copy, 'copy' => 'taglia selezionati' }
      assert_redirected_to :controller => :doc, :action => :show, :id => child.id

      get :paste_child_below_here, { :id => child.id }
      assert_response :success
      assert_template 'sidebar/paste_confirmation'

      post :paste_or_cancel, { 'paste' => 'confermo', 'next_action' => 'paste_child', 'selection' => sel, 'id' => child.id.to_s }
      assert_redirected_to :controller => :doc, :action => :show, :id => child.id

      assert_equal idx, child.children(true).size
      assert_equal parent.id, child.parent.id # re-parenting of this particular child was not performed
      #
      # FIXME: for some reason parent becomes a stale object and cannot be
      #        destroyed as wished
#     #
#     # destroy parent and children
#     #
#     assert parent.reload
#     assert parent.destroy
    end
  end

private

  include Test::Utilities

  def mass_generate_documents(parent, num, klass = Series)
    0.upto(num-1) do
      |n|
      assert d = klass.create_from_form({ :name => random_string + sprintf("_%05d", n), :parent => parent,
                                          :creator => @user, :last_modifier => @user,
                                          :container_type => @ct,
                                          :description_level_position => DescriptionLevel.sottoserie.position }, @s_1)
      assert_valid d
    end
  end

  def create_folder(parent, name)
    assert result  = Folder.create_from_form({ :name => name, :parent => parent,
                                             :creator => @user, :last_modifier => @user,
                                             :container_type => @ct,
                                             :description_level_position => DescriptionLevel.sottoserie.position }, @s_1)
    assert_valid result
    return result
  end

  def generate_clipboard_copy_hash(parent, to_be_copied)
    result = {}
    parent.children(true).each do
      |c|
      result.update(c.id.to_s => 'no')
    end
    to_be_copied.each do
      |id|
      raise "not enough childs for this index (#{id} > #{parent.children.size})" unless id < parent.children.size
      result.update(parent.children[id].id.to_s => 'yes')
    end
    return result
  end

end
