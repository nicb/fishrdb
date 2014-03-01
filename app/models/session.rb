#
# $Id: session.rb 491 2010-04-18 01:53:37Z nicb $
#
# The session class is needed in some special cases, like tests and rake
# tasks. It may harm normal functioning. So  we  define  an  environment
# variable that should be set when needed. Tests always define it.
# 

if RAILS_ENV == 'test' || ENV['FISHRDB_SESSION_NEEDED'] == 'true'
  class Session < ActiveRecord::Base
  end
end
