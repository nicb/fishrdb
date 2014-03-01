#
# $Id: clipboard_item_test.rb 445 2009-09-24 14:19:25Z nicb $
#
require 'test/test_helper'

class ClipboardItemTest < ActiveSupport::TestCase

  fixtures :documents, :sessions, :users

  def setup
    assert @doc = Document.fishrdb_root
    assert @doc.children.reload
    assert @cdoc = @doc.children[0]
    assert @cdoc.children.reload
    assert @u = User.authenticate('staffbob', 'testtest')
    assert @u2 = User.authenticate('bob', 'testtest')
    assert @s_1 = sessions(:one)
    assert @s_1['user'] = @u
    assert @s_2 = sessions(:two)
    assert @s_2['user'] = @u2
    assert @st = SidebarTree.retrieve(@s_1)
    #
    # Since the ClipboardItem objects validate for uniqueness, make sure there
    # are no ClipboardItems allocated yet
    #
    ClipboardItem.find(:all).each { |cli| cli.destroy }
  end

  def test_create_and_destroy
    #
    assert ci = ClipboardItem.create(:sidebar_tree => @st, :document =>  @doc)
    assert ci.valid?
    ci.destroy
    assert ci.frozen?
    #
    assert ci = ClipboardItem.create(:sidebar_tree => @st, :document =>  @doc)
    assert ci.valid?
    @st.destroy # destroying the tree should destroy the clipboard
    error = 0
    begin
      ci.reload
    rescue ActiveRecord::RecordNotFound
      error += 1
    end
    assert_equal 1, error
  end

  def test_associations
    #
    assert ci = ClipboardItem.create(:sidebar_tree => @st, :document =>  @doc)
    assert ci.valid?
    @st.clipboard_items.reload
    assert_equal @doc.name, ci.document.name
    assert_equal ci.document.name, @st.clipboard_items[0].document.name
  end

  def test_validations
    #
    # presence_of
    #
    assert ci = ClipboardItem.create
    assert !ci.valid?
    assert ci = ClipboardItem.create(:sidebar_tree => @st)
    assert !ci.valid?
    assert ci = ClipboardItem.create(:document => @doc)
    assert !ci.valid?
    assert ci = ClipboardItem.create(:sidebar_tree => @st, :document => @doc)
    assert ci.valid?
    ci.destroy
    assert ci.frozen?
    #
    # uniqueness
    #
    assert ci = ClipboardItem.create(:sidebar_tree => @st, :document => @doc)
    assert ci.valid?
    assert ci2 = ClipboardItem.create(:sidebar_tree => @st, :document => @doc)
    assert !ci2.valid?
    #
    assert st2 = SidebarTree.retrieve(@s_2)
    assert ci2 = ClipboardItem.create(:sidebar_tree => st2, :document => @doc)
    assert !ci2.valid?
  end

  def test_association_with_document
    assert ci = ClipboardItem.create(:sidebar_tree => @st, :document =>  @cdoc)
    assert ci.valid?
    @st.clipboard_items.reload
    assert doc = ci.document
    doc.reload
    doc.children.reload
    assert doc.valid?
    #
    # if I destroy the document also the clipboard item should go
    #
    doc.delete_from_form
    assert doc.frozen?
    error = 0
    begin
      ci.reload
    rescue ActiveRecord::RecordNotFound
      error += 1
    end
    assert_equal 1, error
  end

  def test_association_with_sidebar_tree
    assert ci = ClipboardItem.create(:sidebar_tree => @st, :document =>  @cdoc)
    assert ci.valid?
    @st.clipboard_items.reload
    #
    # if I destroy the sidebar_tree also the clipboard item should go
    #
    @st.destroy
    assert @st.frozen?
    error = 0
    begin
      ci.reload
    rescue ActiveRecord::RecordNotFound
      error += 1
    end
    assert_equal 1, error
  end

end
