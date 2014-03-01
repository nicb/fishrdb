#
# $Id: time_segment.rb 613 2012-01-17 01:55:24Z nicb $
#

require 'tdp/pro_tools/data_aggregator'

module BundleGenerator

  class TimeSegment < Base

    attr_reader :source_path, :source_file, :start_time, :end_time

    #
    # +TimeSegment.new(specs)+ produces an absolute time reference
    # segment for a given tape. It is created with the following arguments:
    # +spec+: a 2-element array [:file, [:start, :end]]
    #
    def initialize(spec, sp)
      super(nil)
      raise(InvalidTimeSegmentSpecification, "Invalid time segment specification: #{spec.inspect}") unless test_spec(spec)
      @source_file = spec[0]
      @start_time = Tdp::ProTools::SessionTime.create_from_seconds(spec[1][0])
      @end_time = Tdp::ProTools::SessionTime.create_from_seconds(spec[1][1])
      @source_path = sp
      dot
    end

    include Mp3Helper::Split

    def generate_time_segment(destdir)
      generate_segment(self.source_file, destdir, self.start_time, self.end_time, self.segment_name)
    end

    #
    # +segment_name+: the segment name generated. The generation takes into
    # account the fact that some operating systems cannot deal with special
    # characters cleanly. In particular, the following characters should be
    # avoided: \/:*?"<>|
    #
    def segment_name
      "#{self.start_time.to_s}-#{self.end_time.to_s}".clean_filename_for_dumb_operating_systems
    end

  private

    def test_spec(spec)
      result = true
      [ 'spec', 'spec.size == 2', 'spec[0].is_a?(String)', 'spec[1].size == 2',
        'spec[1][0].is_a?(Numeric)', 'spec[1][1].is_a?(Numeric)' ].each do
        |tst|
        unless eval(tst)
          result = false
          break
        end
      end
      result
    end

    def reference_file(source_file)
      source_file
    end

  end

end
