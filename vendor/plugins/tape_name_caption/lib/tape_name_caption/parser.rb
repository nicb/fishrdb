#
# $Id: parser.rb 554 2010-09-12 16:48:50Z nicb $
#

module TapeNameCaption

  module Parser

    CHUNKER   = Regexp.compile(/[^@\-._]+/)

	  def parse
      pre_correct_minor_errors
      chunks = self.parsed_filename.scan(CHUNKER)
      meth = "parse_#{chunks.size}_tokens"
      begin
        send(meth, chunks)
      rescue NoMethodError
        self.malformed = true
      end
      check_that_parsing_is_correct # sets malformed to true if incorrect
	  end

    include Parse::Map

  private

    def parse_4_tokens(chunks)
      map = build_token_map([:name, :speed, :bitrate, :format])
      name = chunks[map[:name]]
      if name =~ /^(Riv|V[Ss]peed)/
        ch = 'NA'
        num = 'NA'
      else
        ch = name =~ /^B/ ? 'R' : 'L'
        num = name.sub(/^[AB]([0-9]+)/, '\1')
      end
      missing = { :direction => 'STGT', :number => num, :channel => ch }
      tmap = map_tokens(chunks, map, missing)
      common_parse_tokens(tmap)
    end

    def parse_5_tokens(chunks)
      m1 = [:name, :speed, :channel, :bitrate, :format]
      m2 = [:name, :speed, :direction, :bitrate, :format]
      if chunks[2] =~ /RVRS/
        map = build_token_map(m2)
        name = chunks[map[:name]]
        ch = name =~ /^A/ ? 'L' : (name =~ /^B/ ? 'R' : 'NA')
        missing = { :channel => ch, :number => 'NA' }
      else
        map = build_token_map(m1)
        missing = { :direction => 'STGT', :number => 'NA' }
      end
      tmap = map_tokens(chunks, map, missing)
      common_parse_tokens(tmap)
    end

    def parse_6_tokens(chunks)
      map = build_token_map([:name, :speed, :number_or_direction, :channel, :bitrate, :format])
      tmap = map_tokens(chunks, map)
      if tmap[:number_or_direction] =~ /[0-9]+/
        tmap[:number] = tmap.delete(:number_or_direction)
        tmap[:direction] = 'STGT'
      else
        tmap[:number] = '01'
        tmap[:direction] = tmap.delete(:number_or_direction)
      end
      common_parse_tokens(tmap)
    end

    def parse_7_tokens(chunks)
      map = build_token_map([:name, :speed, :direction, :number, :channel, :bitrate, :format])
      tmap = map_tokens(chunks, map)
      common_parse_tokens(tmap)
    end

    def common_parse_tokens(map)
      map.each do
        |k, v|
        method = k.to_s + '='
        self.send(method, v)
      end
    end

    def build_token_map(tokens)
      result = {}
      tokens.each_index { |idx| result.update(tokens[idx] => idx) }
      return result
    end

    def map_tokens(chunks, map, missing = {})
      result = {}
      map.each { |k, v| result[k] = chunks[v] }
      result.update(missing)
      return result
    end

    def pre_correct_minor_errors
      self.parsed_filename.sub!(/Audio 1/, 'Riv@NA')
      self.parsed_filename.sub!(/RivA/, 'Riv@')
      self.parsed_filename.sub!(/VSPEED/, 'Vspeed')
      self.parsed_filename.sub!(/Reverse/, 'RVRS')
      self.parsed_filename.sub!(/@([0-9,]+)REV/, '@\1-RVRS')
    end

    def check_that_parsing_is_correct
      unless self.malformed? # if we already know it's malformed, don't bother
	      REGEXP_MAP.each do
	        |k, v|
	        self.malformed = true unless self.send(k) =~ v[:regexp]
	      end
      end
    end

  end

end
