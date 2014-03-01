#
# $Id: user_test.rb 325 2009-03-07 22:23:32Z nicb $
#
require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  
  fixtures :users, :documents
    
  def setup
  	assert @bob = User.authenticate("staffbob", "testtest")
    assert @longbob = User.authenticate("longbob", "longtest")
    @new_user = User.new(:login => "new_bob",
						 :name  => "NewBob Girgiolon",
						 :email => "girgiolon@girgiolon.com")
  end

  def test_auth  

    assert_equal  @bob, User.authenticate("staffbob", "testtest")    
    assert_nil    User.authenticate("non_bob", "testtest")

  end

  def test_passwordchange
        
    @longbob.change_password("nonbobpasswd")
    @longbob.reload
    assert_equal @longbob, User.authenticate("longbob", "nonbobpasswd")
    assert_nil   User.authenticate("longbob", "longtest")
    @longbob.change_password("longtest")
    assert_equal @longbob, User.authenticate("longbob", "longtest")
    assert_nil   User.authenticate("longbob", "nonbobpasswd")
        
  end
  
  def test_disallowed_passwords

	@new_user.password = @new_user.password_confirmation = "tiny"
    assert !@new_user.save     
    assert @new_user.errors.invalid?('password')

    @new_user.password = @new_user.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !@new_user.save     
    assert @new_user.errors.invalid?('password')
        
    @new_user.password = @new_user.password_confirmation = ""
    assert !@new_user.save    
    assert @new_user.errors.invalid?('password')
        
    @new_user.password = @new_user.password_confirmation = "bobs_secure_password"
    assert @new_user.save
    assert @new_user.errors.empty?
	assert @new_user.destroy
        
  end
  
  def test_bad_logins

    @new_user.password = @new_user.password_confirmation = "bobs_secure_password"

    @new_user.login = "x"
    assert !@new_user.save     
    assert @new_user.errors.invalid?('login')
    
    @new_user.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !@new_user.save     
    assert @new_user.errors.invalid?('login')

    @new_user.login = ""
    assert !@new_user.save
    assert @new_user.errors.invalid?('login')

	@new_user.login = "corrected_login"
    assert @new_user.save  
    assert @new_user.errors.empty?
      
	assert @new_user.destroy
  end


  def test_collision
    @new_user.login  = "staffbob"
    @new_user.password = @new_user.password_confirmation = "bobs_secure_password"
    assert !@new_user.save
  end

  def test_create
    @new_user.login      = "reallynonexistingbob"
    @new_user.password = @new_user.password_confirmation = "bobs_secure_password"
      
    assert @new_user.save
	  assert @new_user.destroy
  end
  
  def test_sha1
    @new_user.password = @new_user.password_confirmation = "bobs_secure_password"
    assert @new_user.save
        
    assert_equal '2145384d305be4772fa54bc7ee74d77a598bd98a', @new_user.password
	  assert @new_user.destroy
  end

#   def test_clipboard
#     assert doc = Document.find(3)
#     assert_equal doc.id, doc.parent.children[doc.position-1].id
# 
#     seldocs = []
#     seldocs << doc
#     assert @bob.clipboard_empty?
#     @bob.add_to_clipboard(seldocs)
#     assert c = @bob.get_clipboard
#     c.children.reload
#     assert_equal c.children.size, c.children.count, "clipboard.size = #{c.children.size} while clipboard.count = #{c.children.count}"
#     assert !@bob.clipboard_empty?, "Clipboard was supposed to be full but @bob.clipboard_empty? returns #{@bob.clipboard_empty?}"
#   end
  
end
