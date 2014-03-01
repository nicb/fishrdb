#
# $Id: application.rb 615 2012-06-07 21:27:49Z nicb $
#
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'submit_tag_fix'

class ApplicationController < ActionController::Base

	before_filter :require_login

  helper :all # include all helpers, all the time
  # protect_from_forgery currently does not work, #13
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  #
  # required by the generated login account management system
  #
  include LoginSystem
  #
  # session user query helper
  #
  include SessionUserHelper

  #
  # this is the quickest way to retrieve the revision number for the
  # repository, grabbed from
  # http://www.ruby-forum.com/topic/105780
  #
  # now we have added a hand-crafted tag in order to get it quickly
  #
  def svn_revision
    unless @svn_revision
      tag = `basename $(grep '\/tags\/' #{RAILS_ROOT}/.svn/entries || echo none)`
      ver = `svnversion -n .`
      if tag == "none\n"
        @svn_revision = ver
      else
        @svn_revision = tag + ' (' + ver + ')'
      end
    end
    @svn_revision
  end

  def self.rails_environment
    return (RAILS_ENV || 'development')[0..2]
  end

  helper_method :svn_revision, ApplicationController::rails_environment

  def button_pressed?(tag)
    return (params.has_key?(tag) and ! params[tag].empty?)
  end

  #
  # the credits page is called from all controllers
  #
  APPLICATION_NAME = '<a href="http://trac.sme-ccppd.org/fishrdb">FIShrdb</a>' unless defined?(APPLICATION_NAME)

  def credits
    @appname = APPLICATION_NAME
    @svn_revision = svn_revision
    render(:action => 'credits')
  end

private
	#
	# +require_login+ is a method used by all controllers to check if we're
  # handling an anonymous user or some staff user
  #
  def require_login
		unless authorized?
			flash[:error] = "Azione non autorizzata"
			redirect_to :controller => :account, :action => :login
		end
	end

	def authorized?
		res = false
		u = session['user']
		res = (u.user_type == :staff || u.user_type == :admin) if u && u.class == User
		res
	end

end
