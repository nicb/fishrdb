#
# $Id: exceptions.rb 598 2011-01-04 07:35:09Z nicb $
#
module Mp3Helper

  class Mp3HelperError < StandardError; end
  class TaintingError < Mp3HelperError; end
  class FatalError < Mp3HelperError; end

  class MissingData < FatalError; end
  class SystemCallFailure < TaintingError; end

end
