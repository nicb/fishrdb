#
# $Id: sidebar_tree_test.rb 445 2009-09-24 14:19:25Z nicb $
#
require 'test/test_helper'

class SidebarTreeTest < ActiveSupport::TestCase

  fixtures :users, :sessions, :documents

  def setup
    assert @user = users(:staffbob)
    assert @s_1 = sessions(:one)
    assert @s_1['user'] = @user
  end

  def test_create_and_destroy
    assert sbt = SidebarTree.create(:session_id => @s_1.session_id)
    assert sbt.valid?
    # initially allocated: root item + children of root only
    num_docs = sbt.root.children.size + 1
    assert_equal num_docs, sbt.documents.size
    sbt.destroy
    assert sbt.frozen?
    assert_equal sbt.documents.size, 0
  end

  def test_find_through_session
    assert sbt = SidebarTree.create(:session_id => @s_1.session_id)
    assert sbt.valid?
    assert found_sbt = SidebarTree.find_by_session_id(@s_1.session_id)
    assert found_sbt.valid?
    assert sbt === found_sbt
  end

  def test_root_of_the_tree
    root_doc = Document.fishrdb_root
    assert sbt = SidebarTree.create(:session_id => @s_1.session_id)
    assert sbt.valid?
    assert sbt.root.document === root_doc
  end

  def test_retrieve
    root_doc = Document.fishrdb_root
    assert sbt = SidebarTree.retrieve(@s_1)
    assert sbt.valid?
    assert sbt.root.document === root_doc
    #
    assert sbt2 = SidebarTree.retrieve(@s_1) # should be identical
    assert sbt2.valid?
    assert sbt2.root.document === root_doc
    assert_equal sbt2.root.document.children.size, root_doc.children.size
  end

  def test_render
    root_doc = Document.fishrdb_root
    params = {}
    assert root = SidebarTree.render(root_doc.id, @s_1, params)
    assert_equal root_doc, root.document
    #
    # test with documents other than root
    #
    ot = false
    all = Document.all
    10.upto(50).each do
      |idx|
      d = all[idx]
      assert d.valid?
      ot = ot ? false : true
      params = { :open_tree => ot }
      assert root = SidebarTree.render(d.id, @s_1, params)
      assert_equal root_doc, root.document
    end
  end

  def traverse(node, &block)
    yield(node)
    node.children.each { |c| traverse(c, &block) }
  end

  def test_only_the_root_folder_should_be_open_in_the_beginning
    assert sbt = SidebarTree.retrieve(@s_1)
    assert sbt.valid?
    assert sbt.root.open?, "root should be :open and it is instead #{sbt.root.status}"
    numi = sbt.sidebar_tree_items.size
    sbt.sidebar_tree_items.each do
      |n|
      unless n === sbt.root
        assert n.closed?, "node #{n.document.name[0..10]}... should be :closed and it is instead #{n.status}"
        numi -= 1
      end
    end
    assert_equal numi, 1 # just the root wasn't done
    sbt.root.children.each do
      |rc|
      traverse(rc) { |n| assert n.closed?, "node #{n.document.name[0..10]}... should be :closed and it is instead #{n.status}" }
    end
  end

  def test_selected_sidebar_tree_item
    assert sbt = SidebarTree.retrieve(@s_1)
    assert sbt.valid?
    sbt.sidebar_tree_items.each do
      |sbi|
      unless sbi === sbt.root
        assert sbi.closed?, "node #{sbi.document.name[0..10]}... should be :closed and it is instead #{sbi.status}"
        sbi.toggle
        assert sbi.open?, "node #{sbi.document.name[0..10]}... should be :open and it is instead #{sbi.status}"
        assert sbi.selected?, "node #{sbi.document.name[0..10]}... should be selected and it is not"
      end
    end
  end
end
