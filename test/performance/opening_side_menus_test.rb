#
# $Id$
#
require 'test/test_helper'
require 'performance_test_help'

class OpeningSideMenusTest < ActionController::PerformanceTest

  fixtures :container_types, :users

  def setup
    assert @ct = container_types(:scatolone)
    assert @ct.valid?
    assert @user = users(:bootstrap)
    assert @user.valid?
    #
    # make sure the Document root exists or create one
    #
    unless (root = Document.fishrdb_root)
      assert root = Folder.create(:name => '__Fondazione_Isabella_Scelsi__', :parent_id => nil, :container_type => @ct,
                                  :description_level_id => DescriptionLevel.fondo.id, :creator => @user, :last_modifier => @user)
      assert root.valid?
    end
    assert @pargs = { :parent => root, :name => 'Test parent', :container_type => @ct, :description_level_id => DescriptionLevel.serie.id, :creator => @user, :last_modifier => @user }
    assert @parent = Folder.create(@pargs)
    assert @parent.valid?
    assert @num_children = 1000
    1.upto(@num_children) do
      |n|
      name = "Test%04d" % n
      args = @pargs.dup
      args.update(:name => name, :parent => @parent)
      assert child = Series.create(args)
      assert child.valid?
    end
    assert_equal @num_children, @parent.children(true).size
    assert_routing("doc/open/#{@parent.id}", { :controller => 'doc', :action => 'open', :id => @parent.id.to_s })
    assert_routing("doc/toggle/#{@parent.id}", { :id => @parent.id.to_s, :open_tree => 'false', :controller => 'doc', :action => 'toggle' }, {}, { :open_tree => 'false' })
    assert @num_openings_closings = 100
  end

  def test_opening_closing_menu
    #
    # do it a number of times to reduce the impact of external methods during
    # profiling
    #
    1.upto(@num_openings_closings) do
	    #
	    # opening
	    #
	    get url_for(:controller => 'doc', :action => 'open', :id => @parent.id)
	    assert_response :redirect
	    #
	    # closing
	    #
	    get url_for(:controller => 'doc', :action => 'toggle', :id => @parent.id.to_s, :open_tree => 'false')
	    assert_response :redirect
    end
  end

end
