#
# $Id: tape.rb 599 2011-01-05 01:04:07Z nicb $
#
module BundleGenerator

  class Tape < Base

    attr_reader :name, :tape_files, :image_files, :meta_files, :segments, :segment_container,
                :time_segments

    def initialize(n, config)
      super(nil)
      @name = n
      config_tape_files(config)
      config_image_files(config)
      config_meta_files(config)
      config_segment_files(config)
    end

    def create_tape_bundle(dest)
      copy(dest)
      generate_tape_segments(dest)
    end

  private

    def copy(dest)
      self.tape_files.each { |tf| tf.copy(dest) }
      self.image_files.each { |ifs| ifs.copy(dest) }
      self.meta_files.each { |mf| mf.copy(dest) }
    end

    def generate_tape_segments(dest)
      segment_container.generate_tape_segments(dest)
      time_segments.each { |ts| ts.generate_time_segment(dest) }
    end

    include FishrdbHelper::Paths

    def config_tape_files(conf)
      paths = config_common(conf, 'files', tape_path(self.name)) { tape_file_lookup(self.name).map { |fn| fn } }
      @tape_files = paths.map { |p| TapeFile.new(p) }
    end

    def config_image_files(conf)
      paths = config_common(conf, 'images', image_path(self.name)) { image_file_lookup(self.name).map { |fn| fn } }
      @image_files = paths.map { |p| ImageFile.new(p) }
    end

    def config_meta_files(conf)
      paths = []
      paths << text_file_lookup(self.name).map { |fn| fn }
      paths << note_file_lookup(self.name).map { |fn| fn }
      @meta_files = paths.flatten.map { |p| MetaFile.new(p) }
    end

    def config_segment_files(conf)
      config_named_segments(conf)
      config_time_segments(conf)
    end

    def config_named_segments(conf)
      @segments = conf && conf.has_key?('fragments') && conf['fragments'] ? conf['fragments'] : []
      @segments.flatten! # just in case there are embedded arrays
      sp = tape_path(name)
      @segment_container = TapeSegmentContainer.new(self, sp)
    end

    def config_time_segments(conf)
      t_segs = conf && conf.has_key?('time_fragments') && conf['time_fragments'] ? conf['time_fragments'] : []
      sp = tape_path(name)
      @time_segments = t_segs.map { |tconf|  TimeSegment.new(tconf, sp) }
    end

    def config_common(conf, key, base_path)
      paths = []
      if conf && conf.has_key?(key) && conf[key]
        conf[key].each { |fn| paths << File.join(base_path, fn) }
      else
        paths = yield
      end
      dot
      paths
    end

  end

end
