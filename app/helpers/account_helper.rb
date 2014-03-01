#
# $Id: account_helper.rb 12 2007-10-01 02:56:42Z nicb $
#
module AccountHelper

private
	ANONYMOUS_USER = User.find(:first, :conditions => ["login = ?", 'anonymous'])

public

	def back_to_anonymous
		return ANONYMOUS_USER
	end

	def last_administrator?(user)
		result = false
		if user.user_type.to_s == 'admin'
			admins = User.find(:all, :conditions => ["user_type = ?", 'admin'])
			if admins.size <= 1
				result = true
			end
		end

		return result
	end

	def anonymous_user?(user)
		return user.login == ANONYMOUS_USER.login
	end

end # AccountHelper module
