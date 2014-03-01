#
# $Id: user.rb 327 2009-03-09 21:34:37Z nicb $
#
require 'digest/sha1'
require_dependency 'search_system'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base

  extend SearchHelper::Model::ClassMethods

# make_searchable  [ :name, :login, :email ]

  belongs_to	:clipboard, :class_name => "Folder", :conditions => "user_type = 'staff' or user_type = 'admin'", :foreign_key => "clipboard_id"

  def self.authenticate(login, pass)
    find(:first, :conditions => ["login = ? AND password = ?", login, sha1(pass)])
  end  

  def change_password(pass)
    update_attribute "password", self.class.sha1(pass)
  end
    
  protected

  def self.sha1(pass)
    Digest::SHA1.hexdigest("-FisHRDB_salt--#{pass}--")
  end
    
  before_create :crypt_password
  
  def crypt_password
    write_attribute("password", self.class.sha1(password))
  end

  validates_length_of :login, :within => 3..40
  validates_length_of :name, :within => 0..255
  validates_length_of :password, :within => 5..41
  validates_presence_of :login, :password, :password_confirmation, :email, :on => :create
  validates_uniqueness_of :login, :on => :create
  validates_confirmation_of :password, :on => :create     

	#
	# user level queries
	#
private
	def _user_type_?(type)
		return user_type == type
	end

public
	#
	# permissions are in increasing order of magnitude.
	# permissions accumulate with level (i.e. 'specialist' has all 'anonymous'
	# permissions plus... etc.)
	#
	# anonymous and public users have only basic permissions: look at records.
	#
	def anonymous?
		return login == 'anonymous'
	end

	def public?
		return _user_type_?(:public)
	end
	#
	# specialist: allowed to download music, etc.
	#
	def specialist?
		return _user_type_?(:specialist)
	end

	#
	# staff: allowed to CRUD, allowed to see 'private' records, etc.
	#
	def staff?
		return _user_type_?(:staff)
	end

	#
	# admin: allowed to admin users
	#
	def admin?
		return _user_type_?(:admin)
	end

	#
	# editors are allowed to edit records (basically only staff and
	# admin)
	#
	def editor?
		return staff? || admin?
	end

	#
	# end users are allowed to view only filled-in (non-empty) records, no editing
	# allowed
	#
	def end_user?
		return anonymous? || specialist?
	end

	#
	# allowed_to_listen users are allowed to listen/download music
	#
	def allowed_to_listen?
		return editing_user? || specialist_user?
	end

	#
	# what follows is just for loading the database
	#

	include YamlLoader

	def User.create_from_yaml_data(tree, yaml_data)
		$stderr.printf("Creating user: %s\n", yaml_data["login"])
		
		user = User.new(yaml_data)
		user.save!

		return user
	end

	def User.create_from_yaml_file
		YamlLoader.do_create_from_yaml_file(User, 'users.yml')
	end

end
