#
# $Id: session_user_helper.rb 326 2009-03-08 22:30:58Z nicb $
#

#
# user type queries available from controllers
#
module SessionUserHelper

public

	def session_user
		return session['user']
	end

private

	def am_I
		return session_user
	end

public
	#
	# permissions are in increasing order of magnitude.
	# permissions accumulate with level (i.e. 'specialist' has all 'anonymous'
	# permissions plus... etc.)
	#
	# anonymous users have only basic permissions: look at records.
	#
	def anonymous_session?
		return am_I.anonymous? if am_I 
	end

	#
	# same for public users
	#
	def public_session?
		return am_I.public? if am_I
	end

	#
	# specialist: allowed to download music, etc.
	#
	def specialist_session? 
		return am_I.specialist? if am_I
	end

	#
	# staff: allowed to CRUD, allowed to see 'private' records, etc.
	#
	def staff_session?
		return am_I.staff? if am_I
	end

	#
	# admin: allowed to admin users
	#
	def admin_session?
		return am_I.admin? if am_I
	end

	#
	# editing users are allowed to edit records (basically only staff and
	# admin)
	#
	def editor_session?
		return am_I.editor? if am_I
	end

	#
	# end users are allowed to view only filled-in (non-empty) records, no editing
	# allowed
	#
	def end_user_session?
		return am_I.end_user? if am_I
	end

	#
	# allowed_to_music users are allowed to listen/download music
	#
	def allowed_to_listen_session?
		return am_I.allowed_to_listen? if am_I
	end

#	#
#	# is my clipboard empty?
#	#
#	def clipboard_empty?
#		return am_I.clipboard_empty? if am_I
#	end

end # SessionUserHelper module
