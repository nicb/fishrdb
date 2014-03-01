#
# $Id: tape_segment.rb 599 2011-01-05 01:04:07Z nicb $
#

require 'tdp/pro_tools/data_aggregator'

module BundleGenerator

  class TapeSegment < Base

    attr_reader :segment, :start_segment, :end_segment, :start_region, :end_region, :start_time, :end_time,
                :source_path

    def initialize(seg, container)
      super(nil)
      @segment = seg
      (@start_segment, @end_segment) = parse_segments(seg)
      create_tape_segment(container)
      dot
    end

    include Mp3Helper::Split

    def generate_tape_segment(destdir)
      generate_segment(self.start_region.source_file, destdir,
                       self.start_region.source_start_time,
                       self.end_region.source_end_time,
                       self.segment_name)
    end

    def segment_name
      self.segment.gsub(/\*/,'').gsub(/@[0-9].*$/, '')
    end


  private

    def create_tape_segment(container)
      @start_region = region_finder(container.pro_tools_session, :start_segment)
      @end_region   = region_finder(container.pro_tools_session, :end_segment)
      @start_region = @start_region.first
      @end_region   = @end_region.first
      @start_time   = self.start_region.start_time
      @end_time     = self.end_region.end_time
      @source_path  = container.source_path
    end

    REGION_REGEXP_PATTERN = Regexp.new(/\*$/)

    def region_finder(pts_session, method)
      result = nil
      key_or_pattern = self.send(method)
      if key_or_pattern =~ REGION_REGEXP_PATTERN
        p = key_or_pattern.sub(REGION_REGEXP_PATTERN, '')
        result = pts_session.find_region_like(p)
      else
        result = [ pts_session.find_region(key_or_pattern) ]
      end
      raise(RegionMissing, "No region found for #{method.to_s} /#{self.send(method)}/") if result.blank? || result.first.blank?
      name = self.source_path ? File.basename(self.source_path) : ''
      raise(AmbiguousRegionName, "Found several possibilities for #{method.to_s} /#{self.send(method)}/ [#{result.map { |r| r.name }.join(', ')}] for #{name} - please disambiguate") if result.size > 1
      result
    end

    def parse_segments(seg_string)
      result = seg_string.split('-')
      result << result.first if result.size == 1
      result
    end

    def fishrdb_output_filename(srcfile)
      clean_segment_name = self.segment.gsub(/\*/,'').gsub(/@[0-9].*$/, '')
      frag_file = lofi_file_prefix(srcfile) + ("-%s" % [ clean_segment_name ] )
    end

  end

  class TapeSegmentContainer < Base

    attr_reader :pro_tools_session, :tape_segments, :source_path

    def initialize(tape, sp)
      super(nil)
      @source_path = sp
      @pro_tools_session = find_pro_tools_data(tape)
      @tape_segments = create_tape_segments(tape)
      dot
    end

    def generate_tape_segments(destdir)
      self.tape_segments.each { |ts| ts.generate_tape_segment(destdir) }
    end

  private

    def find_pro_tools_data(tape)
      pts_session = tape.meta_files.map { |mf| mf.path }.grep(/#{tape.name}.txt$/).first
      return Tdp::ProTools::DataAggregator.new(pts_session)
    end

    def create_tape_segments(tape)
      tape.segments.map { |f| TapeSegment.new(f, self) }
    end

  end

end
