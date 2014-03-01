#
# $Id: string.rb 541 2010-09-07 06:08:21Z nicb $
#

require 'string_extensions'

module Test

  module Utilities

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


#    #
#    # FIXME: the 'Functional' module is probably useless. Test objects should
#    # use the assert_select() methods directly. If a more in-depth testing of
#    # the response bodies is required, perhaps cucumber + webrat should be
#    # used instead
#    #
#    module Functional

#    public

#      include ActionController::Assertions::SelectorAssertions

#      def post_response_body(action, submit_action, pars = nil, sess = {}, fl = {})
#        method = 'submit_' + submit_action.to_s + '_parse_response_body'
#        pars = send(method, pars)
#        pars['action'] = action.to_s
#        return post(action, pars, sess, fl)
#      end

#			def parse_response_body
#        result = {}
#        tags = css_select('input') + css_select('select') + css_select('textarea')
#        if block_given?
#	        tags.each do
#	          |t|
#	          yield(t, result)
#	        end
#        else
#          result = tags
#        end
#        return result
#			end

#      def parse_and_fill_response_body
#        return parse_response_body { |t, r| fill_result_hash(t, r) }
#      end

#      def submit_save_parse_response_body(pars = nil)
#        # 'cancel' is the parameter *to be removed*
#        return prepare_parse_response_body('cancel', pars)
#      end

#      def submit_cancel_parse_response_body(pars = nil)
#        # key is the parameter *to be removed*
#        key = 'save'
#        key = 'update' if pars && pars.has_key?('update')
#        return prepare_parse_response_body(key, pars)
#      end

#    private

#      def prepare_parse_response_body(param_to_be_removed, pars = nil)
#        pars = parse_response_body unless pars
#        pars.delete(param_to_be_removed)
#        pars.update('controller' => @controller.params['controller']) if @controller
#        return pars
#      end

#      def arrange_hash_keys_and_value(tag)
#        n = tag.attributes['name']
#        v = case tag.name
#        when 'input' : v = tag.attributes['value']
#        when 'select' : tag.children.map { |c| c.attributes['value'] if c.tag?  && c.attributes['selected'] == 'selected' }.compact.first
#        when 'textarea' : tag.children[0].content
#        end
#        v = v.blank? ? '' : v
#        fields = n.split(/[\[\]]+/).map { |f| "'" + f.to_s + "'" }
#        return [ fields, v ]
#      end

#      def build_remaining_hash_string(keys, value)
#        result = keys.join(' => { ')
#        result += (" => '" + value + "' " + ('}' * (keys.size-1)))
#        return result
#      end

#      def fill_result_hash(tag, result)
#        (keys, value) = arrange_hash_keys_and_value(tag)
#        kstring = 'result'
#        idx = 0
#        keys.each do
#          |k|
#          if eval(kstring + ".has_key?(#{k})")
#            kstring += '[' + k + ']'
#          else
#            kstring += '.update(' + build_remaining_hash_string(keys[idx..keys.size-1], value) + ')'
#            break
#          end
#          idx += 1
#        end
#        eval(kstring)
#        return result
#      end

#    public
#      #
#      # arg classes used to produce credible creation outputs directly
#      # from the forms
#      #
#		  class ArgTypeNotImplmented < StandardError
#		  end
#		
#		  class TypeCreationArg

#        include Test::Utilities

#        def produce
#          return type_produce.to_s
#        end
#		    def type_produce
#		      raise(ArgTypeNotImplemented, "The type #{self.class.name} has not been implemented")
#		    end
#		  end
#		
#		  class StringCreationArg < TypeCreationArg
#		    def type_produce
#		      return random_string
#		    end
#		  end
#		
#		  class FixnumCreationArg < TypeCreationArg
#		    def type_produce
#		      return (rand()*10).round
#		    end
#		  end
#		
#		  class BooleanCreationArg < TypeCreationArg
#		    def type_produce
#		      return rand() < 0.5
#		    end
#		  end
#		
#		  class DateCreationArg < TypeCreationArg
#		    def type_produce
#		      return ExtDate::Base.new(DateTime.now + ((rand()*12).round - 6).months)
#		    end
#		  end
#		
#		  class YearCreationArg < TypeCreationArg
#		    def type_produce
#		      return ExtDate::Year.new(DateTime.now + ((rand()*10).round - 5).years)
#		    end
#		  end

#      class TimeCreationArg < TypeCreationArg
#		    def type_produce
#		      return Time.now + ((rand()*10).round - 5).hours
#		    end
#      end

#      STRING = StringCreationArg.new unless defined?(STRING)
#      NUM    = FixnumCreationArg.new unless defined?(NUM)
#      BOOL   = BooleanCreationArg.new unless defined?(BOOL)
#      DATE   = DateCreationArg.new unless defined?(DATE)
#      YEAR   = YearCreationArg.new unless defined?(YEAR)
#      TIME   = TimeCreationArg.new unless defined?(TIME)

#    end

  end

end
