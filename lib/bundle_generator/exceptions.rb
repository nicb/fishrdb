#
# $Id: exceptions.rb 583 2010-12-19 01:32:18Z nicb $
#
module BundleGenerator

  class BundleGeneratorError < StandardError; end
  class TaintingError < BundleGeneratorError; end
  class FatalError < BundleGeneratorError; end

  class SystemConfigurationMissing < FatalError; end
  class OutputFilenameMissing < FatalError; end

  class AmbiguousRegionName < TaintingError; end
  class RegionMissing < TaintingError; end
  class InvalidTimeSegmentSpecification < TaintingError; end
  class SystemCallFailure < TaintingError; end

end
