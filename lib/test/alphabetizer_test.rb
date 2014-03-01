#
# $Id: alphabetizer_test.rb 612 2011-06-13 02:09:14Z nicb $
#

require File.join(File.dirname(__FILE__), ['..'] * 2, 'test', 'test_helper')

class AlphabetizerTest < ActiveSupport::TestCase

  fixtures	:container_types, :users

  def setup
    assert @user  = User.authenticate('bootstrap', '__fishrdb_bootstrap__')
    assert @user.valid?
    assert @ct = container_types(:scatolone)
    assert @ct.valid?
    assert @dl_id = DescriptionLevel.serie.id
    assert @common_args = { :container_type => @ct, :description_level_id => @dl_id, :creator => @user, :last_modifier => @user }
    assert args = @common_args.dup
    assert args.update(:name => 'parent')
    assert @parent_doc = Folder.create(args)
    assert @parent_doc.valid?, "Invalid parent: #{@parent_doc.errors.full_messages.join(', ')}"
  end

  def test_alphabetize_function
    assert children_names = %w([Atest] 29Btest Ctest D29test)
    assert names_should_be = %w(A B C D)
    assert should_be = {}
    #
    # create un-alphabetized children
    #
    children_names.each_with_index do
      |name, idx|
      assert args = @common_args.dup
      assert args.update(:parent => @parent_doc, :name => name)
      assert s = Series.create(args)
      assert s.valid?, "Invalid child: #{s.errors.full_messages.join(', ')}"
      assert should_be.update(names_should_be[idx] => s)
    end
    assert_equal children_names.size, @parent_doc.children(true).size
    assert_equal children_names, @parent_doc.children(true).map { |c| c.name }
    #
    # now alphabetize them
    #
    assert alph = Alphabetizer.new(@user.login, @ct.container_type, @parent_doc.name)
    assert alph.alphabetize
    should_be.keys.sort.each_with_index do
      |key, idx|
      assert_equal key, @parent_doc.children(true)[idx].name
      assert_equal should_be[key], @parent_doc.children(true)[idx].children(true).first
    end
  end

end
