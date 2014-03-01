#
# $Id: exceptions.rb 538 2010-08-23 00:19:46Z nicb $
#

module FindOptionHelper

  class FindOptionHelperException < StandardError; end

  class OnlyOneOptionAllowed < FindOptionHelperException; end

  class FindClassMismatch < FindOptionHelperException; end

  class PureVirtualMethodCalled < FindOptionHelperException; end

end
