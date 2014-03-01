#
# $Id: random_string.rb 539 2010-09-05 15:53:58Z nicb $
#

class String

  def escape_everything
    return Regexp.escape(self).gsub(/(["`'@#])/, '\\\\\1')
  end

end

module SearchEngine

	module Test
	
	  module Utilities

      module RandomString
	
		    class CharacterClass
		      attr_reader :start_chr, :end_chr
		
		      def initialize(s, e)
		        @start_chr = s
		        @end_chr = e
		      end
		
		      def random
		        return ((rand() * (end_chr - start_chr)).round + start_chr).chr
		      end
		
		    end
		
		    class ASCIICharacter < CharacterClass
		    end
		
		    class Latin1Character < CharacterClass
		    end
		
		    class UTF8Character < CharacterClass
		      DEFAULT_CHARSET = 195
		
		      attr_reader :charset
		
		      def initialize(s, e, chset = DEFAULT_CHARSET)
		        @charset = chset
		        return super(s, e)
		      end
		
		      def random
		        return (charset.chr + super)
		      end
		
		    end
		
			  def random_string
		      return common_random_string(ASCIICharacter.new(?a, ?z), ASCIICharacter.new(?A, ?Z), ASCIICharacter.new(?0, ?9))
			  end
		
		    def random_string_ascii
		      return common_random_string(ASCIICharacter.new(32, 126)) # from space to ~
		    end
		
		    def random_string_latin_1
		      return common_random_string(ASCIICharacter.new(32, 126), Latin1Character.new(192, 255)) # from space to ~, plus latin-1 chars
		    end
		
		    def random_string_utf8
		      return common_random_string(ASCIICharacter.new(?a, ?z), ASCIICharacter.new(?A, ?Z), ASCIICharacter.new(?0, ?9), UTF8Character.new(129, 191)) # from space to ~, plus UTF-8 Euro chars
		    end
		
		    def create_random_strings(how_many = 10, min = 3)
		      return common_create_random_strings(:random_string, how_many, min)
		    end
		
		    def create_random_strings_ascii(how_many = 10, min = 3)
		      return common_create_random_strings(:random_string_ascii, how_many, min)
		    end
		
		    def create_random_strings_latin_1(how_many = 10, min = 3)
		      return common_create_random_strings(:random_string_latin_1, how_many, min)
		    end
		
		    def create_random_strings_utf8(how_many = 10, min = 3)
		      return common_create_random_strings(:random_string_utf8, how_many, min)
		    end
		
			  def create_random_names(user)
			    name_pool = []
			    0.upto((rand() * 3.0).round) do
			      name_pool << Name.find_or_create(:last_name => random_string, :first_name => random_string, :creator_id => user.id, :last_modifier_id => user.id)
			    end
			    return name_pool
			  end
		
		  private
		
		    #
		    # +common_random_string+ expects the following arguments:
		    # - one or more CharacterClass-es
		    #
		    def common_random_string(*args)
			    string = ''
			    0.upto((rand() * 20.0).round) do  
		        which_cc = (rand()*(args.size-1)).round
		        string += args[which_cc].random
			    end
		      # make sure regexp and other characters get properly escaped
		      # and that we return a proper multibyte string
			    return ActiveSupport::Multibyte::Chars.new(string.escape_everything)
		    end
		
		    def common_create_random_strings(method, how_many = 10, min = 3)
		      string_pool = []
		      total = how_many - min
		      pool_size = ((rand() * total.to_f).round) + min # min..total
			    0.upto(pool_size-1) do
		        string_pool << send(method)
			    end
			    return string_pool.uniq
		    end

      end
	
	  end
	
	end

end
