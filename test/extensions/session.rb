#
# $Id: session.rb 486 2010-04-04 21:33:39Z nicb $
#
# This is required to make the rake test:functionals task run properly :(
#

class ActionController::TestSession
  attr_reader :session_id
end
