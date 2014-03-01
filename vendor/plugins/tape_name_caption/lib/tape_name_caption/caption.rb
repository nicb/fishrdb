#
# $Id: caption.rb 555 2010-09-12 19:53:28Z nicb $
#

module TapeNameCaption

  class Caption
	  attr_reader :full_filename, :filename, :parsed_filename
    attr_accessor :name, :speed, :channel, :direction, :number, :bitrate, :format, :malformed
	
	  def initialize(full_name)
      @full_filename = full_name
	    @filename = File.basename(full_name)
      @parsed_filename = @filename.dup
      @malformed = false
      parse
      return self
	  end

    def url_filename
      return self.full_filename.sub(/#{TapeNameCaption::Constants::PUBLIC_ROOT}/, '')
    end

    alias :malformed? :malformed

    include TapeNameCaption::Display
	
  private

	  include TapeNameCaption::Parser
    include TapeNameCaption::Info

  end

end
