#
# $Id: intl_error_extensions_test.rb 343 2009-03-22 22:57:05Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

require 'errors_intl_extensions'

class IntlErrorExtensionsTest < ActiveSupport::TestCase

  #
  # fixture load order is important!
  #
	fixtures	:users, :documents
  
  require File.dirname(__FILE__) + '/authority_record_test_object'

  def setup
    assert @user     = User.authenticate('staffbob', 'testtest')
    assert @doc0     = Document.find_by_name('Partiture Giacinto Scelsi')
	end

  def test_italian_error_extensions
    attrs = { :name => 'Ginevra', :creator => @user, :last_modifier => @user }
    assert @sn0 = @doc0.create_site_name_record(@user, attrs)
    assert @sn0.valid?
    assert @sn1 = SiteName.create(attrs)
    assert !@sn1.valid?
    assert_equal @sn1.errors.size, 1
    @sn1.errors.italian_each do
      |it_attr, msg|
      assert_equal it_attr, 'il nome'
    end
  end

end
