#
# $Id: sidebar_tree_item_test.rb 618 2012-09-23 04:40:09Z nicb $
#
require 'test/test_helper'

class SidebarTreeItemTest < ActiveSupport::TestCase

  fixtures :users, :sessions, :documents

  def setup
    assert @doc = documents(:fondo_GS)
		assert @doc.valid?
    assert @doc.children.reload
    assert @cdoc = @doc.children[0]
    assert @cdoc.children.reload
    assert @u = User.authenticate('staffbob', 'testtest')
    assert @u2 = User.authenticate('editbob', 'testtest')
    assert @s_1 = sessions(:one)
    assert @st = SidebarTree.retrieve(@s_1)
    assert @s_2 = sessions(:two)
  end

  def test_create_and_destroy
    #
    # since the SidebarTreeItem validate for uniqueness, make sure there are
    # no SidebarTreeItem allocated yet
    #
    SidebarTreeItem.find(:all).each { |sti| sti.destroy }
    #
    assert sti = SidebarTreeItem.create(:sidebar_tree => @st, :document =>  @doc)
    assert sti.valid?
    sti.destroy
    assert sti.frozen?
  end

  def test_open_close
    assert sti = @st.sidebar_tree_items.find_by_document_id(@doc.id)
    assert sti.valid?
    assert_equal sti.status, :closed
    assert sti.closed?
    assert !sti.open?
    sti.open
    sti.reload
    assert_equal sti.status, :open
    assert sti.open?
    assert !sti.closed?
    assert sti.close
    assert sti.closed?
    assert !sti.open?
    #
    sti.open
    assert stib = @st.sidebar_tree_items.find_by_document_id(@cdoc.id)
    assert stib.valid?
  end

  def test_children
    num_children = @doc.children.size
    assert sti = @st.sidebar_tree_items.find_by_document_id(@doc.id)
    assert sti.valid?
    assert sti.open
    assert sti.open?
    assert_equal sti.children.size, num_children
    n = 0
    sti.children.each_index do
      |i|
      assert sti.children[i].document === @doc.children[i]
      n += 1
    end
    assert_not_equal n, 0
  end

  def test_public_children
    num_children = @doc.children.size
    assert num_children > 0
    @doc.children.last.public_visibility = false
    assert_equal num_children - 1, num_pchildren = @doc.public_children.size
    assert sti = @st.sidebar_tree_items.find_by_document_id(@doc.id)
    assert sti.valid?
    assert sti.open
    assert sti.open?
    assert_equal num_pchildren, sti.public_children.size
  end

  def test_compare_methods
    assert sti_root = @st.sidebar_tree_items.find_by_document_id(@doc.id)
    assert sti_root.open
    assert sti_root.open?
    assert sti_0 = @st.sidebar_tree_items.find_by_document_id(@cdoc.id)
    assert sti_0.valid?
    assert sti_same = @st.sidebar_tree_items.find_by_document_id(@cdoc.id)
    assert sti_same.valid?
    assert sti_diff = @st.sidebar_tree_items.find_by_document_id(@doc.id)
    assert sti_diff.valid?
    assert sti_new = @st.sidebar_tree_items.create(:document => @cdoc) # new, so not the same
    #
    # comparisons
    #
    assert sti_0 == sti_same
    assert !(sti_0 == sti_diff)
    assert !(sti_0 == sti_new)
    #
    assert sti_0 === sti_same
    assert !(sti_0 === sti_diff)
    assert !(sti_0 === sti_new)
  end

  def test_the_sidebar_controller_toggle
    @st.sidebar_tree_items[0].open # make sure the root directory is open
    num_sbits = @st.sidebar_tree_items
    docs = Document.find(:all, :conditions => ["name = 'Archivio Privato' or name = 'Archivio Musicale'"])
    docs.each do
      |d|
      assert sbi = @st.find_sidebar_item(d.id)
      assert_equal :closed, sbi.status, "status of sbti #{sbi.document.name[0..9]}... should be :closed but instead it is #{sbi.status}"
      sbi.toggle
      assert_equal :open, sbi.status, "status of sbti #{sbi.document.name[0..9]}... should be :open but instead it is #{sbi.status}"
      assert sbi.selected?, "selection status of sbti #{sbi.document.name[0..9]}... should be true but instead it is #{sbi.selected?}"
      sbi.toggle
      assert_equal :closed, sbi.status, "status of sbti #{sbi.document.name[0..9]}... should be :closed but instead it is #{sbi.status}"
    end
    @st.reload
    num_sbits.each_with_index do
      |sbti, i|
      assert_equal sbti, @st.sidebar_tree_items[i], "sbti(#{sbti.document.id}, #{sbti.document.name[0..10]}...) and @st.sbti[#{i}](#{@st.sidebar_tree_items[i].document.id}, #{@st.sidebar_tree_items[i].document.name[0..10]}...) are not equal"
    end
  end

  def test_multiple_openings_of_top_directories
    initial_array = @st.sidebar_tree_items
    start_size = initial_array.size
    @st.sidebar_tree_items.each do
      |sbi|
      unless sbi === @st.root
        0.upto(99) do
	        assert sbi.closed?, "node #{sbi.document.name[0..10]}... should be :closed and it is instead #{sbi.status}"
	        sbi.toggle
          @st.reload
	        assert sbi.open?, "node #{sbi.document.name[0..10]}... should be :open and it is instead #{sbi.status}"
          assert sbi.selected?, "node #{sbi.document.name[0..10]}... should be selected and it is not"
	        sbi.toggle
          @st.reload
	        assert sbi.closed?, "node #{sbi.document.name[0..10]}... should be :closed and it is instead #{sbi.status}"
          assert sbi.selected?, "node #{sbi.document.name[0..10]}... should be selected and it is not"
        end
      end
      @st.reload
      assert_equal initial_array, @st.sidebar_tree_items[0..start_size-1]
         "after processing SidebarTreeItem #{sbi.document.name[0..10]}... the two sbti sets are not equal (#{initial_array} <> #{@st.sidebar_tree_items[0..start_size-1]}"
    end
    @st.reload
    initial_array.each_with_index do
      |ia, i|
      assert_equal ia, @st.sidebar_tree_items[i],
        "after processing all SidebarTreeItems the two sbti sets are not equal (#{ia.inspect} <> #{@st.sidebar_tree_items[i].inspect})"
    end
  end

  def test_clipboard
    assert sti = @st.sidebar_tree_items[1]
    assert sti.copy_to_clipboard
    sti.reload
    assert_equal 'yes', sti.copied_to_clipboard
    assert sti.copied_to_clipboard?
    assert sti.remove_from_clipboard
    sti.reload
    assert !sti.copied_to_clipboard?
    #
    assert sti.copy_to_clipboard
    sti.reload
    SidebarTreeItem.clear_clipboard(@st)
    sti.reload
    assert_equal 'no', sti.copied_to_clipboard
    assert !sti.copied_to_clipboard?
  end

  def test_class_find_item
    #
    # existing document
    #
    assert d_id = @st.sidebar_tree_items[1].document.id
    assert sti = SidebarTreeItem.find_item(@st, d_id)
    #
    # non-existing document
    #
    assert d_id = -1
    assert !sti = SidebarTreeItem.find_item(@st, d_id)
  end

  def test_document_association
    assert sti = @st.sidebar_tree_items[1]
    assert doc = sti.document
    assert re_sti = doc.sidebar_tree_item(@s_1)
    assert sti.valid?
    assert re_sti.valid?
    assert doc.valid?
  end

  def test_dependency_from_document
    assert sti = @st.sidebar_tree_items[1]
    assert doc = sti.document
    assert sti.valid?
    assert doc.valid? 
    doc.reload
    doc.children.reload
    doc.delete_from_form
    error = 0
    begin
      sti.reload # should raise ActiveRecord::RecordNotFound
    rescue ActiveRecord::RecordNotFound
      error += 1
    end
    assert_equal 1, error
  end

  def test_children_cache
    assert sti = @st.sidebar_tree_items.find_by_document_id(@doc.id)
    assert sti.open
    assert sti.open?
    assert !sti.children.empty?
    assert !sti.instance_variables.grep(/@children_cache/).empty?
    assert sti.close
    assert sti.closed?
    assert !sti.instance_variables.grep(/@children_cache/).empty?
    assert sti.open
    assert sti.open?
    assert !sti.children.empty?
  end

  def test_expose
    assert sti = @st.sidebar_tree_items.find_by_document_id(@doc.id)
    assert !sti.instance_variables.include?('@children_cache')
    assert sti.open
    assert sti.instance_variables.include?('@children_cache')
    assert !sti.expose_children.empty?
  end

  def test_selection
    assert sti = @st.sidebar_tree_items[1]
    assert sti.open
    assert sti.selected?
    assert_equal sti.sidebar_tree.selected_item_id, sti.id
    assert_equal 'selected', sti.selection_id_tag
  end

  def test_user_separation
    assert st2 = SidebarTree.retrieve(@s_2)
    assert sti1 = @st.sidebar_tree_items[1]
    assert sti2 = st2.sidebar_tree_items[1]
    assert sti1.open
    assert sti1.selected?
    assert !sti2.selected?
    assert_equal 2, sti1.document.sidebar_tree_items.size
  end

end
