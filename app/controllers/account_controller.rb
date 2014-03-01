#
# $Id: account_controller.rb 615 2012-06-07 21:27:49Z nicb $
#
class AccountController < ApplicationController

  include AccountHelper

	skip_before_filter :require_login

private

  def full_session_reset
    if session_user
      sbt = SidebarTree.find_by_session_id(session.session_id)
      sbt.destroy if sbt
    end
    reset_session
  end

public

  def login
    full_session_reset
    case request.method
      when :post
        if session['user'] = User.authenticate(params['user']['login'], params['user']['password'])
          redirect_to :controller => "doc", :action => "front" # , :protocol => "https://"
        else
          flash['notice']  = "Login fallito (#{$!})"
          @login    = params['user']['login']
      end
    end
  end
  
  def signup
    case request.method
      when :post
        @user = User.new(params['user'])
        
        if @user.save      
          if session['user'] = User.authenticate(@user.login, params['user']['password'])
            redirect_to :action => "login" # , :protocol => "https://"
		  else
          	flash['notice']  = "Login fallito (#{$!})"
		  end
        end
      when :get
        @user = User.new
    end      
  end  

private

  def delete(id)
  	@user = User.find(id)
  	@user.destroy
  end  
    
public

  def logout
  full_session_reset
	redirect_to(:controller => :pview, :action => :index)
  end
    
  def admin
  	@users = User.find(:all, :order => :login)
  end

  def update_accounts
  	params['user'].each do
		|k, v|
		id = k.to_i
		if v["delete"].to_i == 1
			delete(id)
		else
			v.delete('delete')
			user = User.find(id)
			if !user.update_attributes!(v)
				msg = "Aggiornamento dell'utente #{user.login} fallito"
				flash['notice'] = flash['notice'] ? flash['notice'] + "\n" + msg : msg
			end
		end
	end
  	redirect_to(:action => 'admin')
  end

  def cancel
	redirect_to(:controller => 'doc', :action => 'front')
  end
end
