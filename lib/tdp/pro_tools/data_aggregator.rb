#
# $Id: data_aggregator.rb 595 2011-01-02 10:40:10Z nicb $
#

pts_cwd = File.dirname(__FILE__)
require pts_cwd + '/exceptions'
require pts_cwd + '/session_time'
require pts_cwd + '/region'
require pts_cwd + '/lexer'

module Tdp

  module ProTools

    class DataAggregator

      attr_reader :filename
      attr_accessor :regions, :tracks

      def initialize(f)
        @filename = f
        @regions = {}
        @tracks = {}
        aggregate
      end

      def find_region_like(pattern)
        ks = self.regions.keys.grep(/#{pattern}/)
        ks.map { |k| self.regions[k] }
      end

      def find_region(key)
        return self.regions[key]
      end

      def parse # required by the rake db:tapes:create task
        aggregate
      end

    private

      def aggregate
        l = Tdp::ProTools::Lexer::Scanner.new(self.filename)
        pts_data = l.pro_tools_session
        thread_region_source_files(pts_data)
        reg_sequences = thread_region_data(pts_data)
        calculate_source_timings
      end

      def thread_region_source_files(pts_data)
        pts_data.regions_in_session.regions.each do
          |r|
          raise(DuplicateRegion,"Internal Error: attempt to duplicate region #{r.region} for session #{File.basename(self.filename, '.txt.')}") if self.regions.has_key?(r.region)
          self.regions.update(r.region => Region.new(r.region, r.file))
        end if pts_data
      end

      def thread_region_data(pts_data)
        region_sequences = {}
        master_tracks = pts_data ? pts_data.track_listing.find_track_like(/^CH/) : []
        master_tracks.each do
          |mt|
          self.tracks.update(mt.name => Track.new(mt.name)) 
          mt.events.each do
            |e|
            raise(RegionNotFound, "Internal Error: region #{e.region_name} not found") unless self.regions.has_key?(e.region_name)
            reg = self.regions[e.region_name]
            reg.add_event(e)
            tracks[mt.name].regions << reg
            reg.track_ref = tracks[mt.name]
            region_sequences[reg.source_file] = [] unless region_sequences.has_key?(reg.source_file)
            region_sequences[reg.source_file] << reg
          end
        end
        region_sequences
      end

      def calculate_source_timings
        last_source = {}
        tracks.values.each do
          |tr|
          tr.regions.each do
            |r|
            last_source.update(r.source_file => 0.0) unless last_source.has_key?(r.source_file)
            cur_cm = last_source[r.source_file]
            r.source_start_time = SessionTime.create_from_length(cur_cm, r.speed)
            r.source_end_time = r.source_start_time + r.duration
            last_source[r.source_file] = r.source_end_time.to_cm(r.speed)
          end
        end
      end

    end

  end

end
