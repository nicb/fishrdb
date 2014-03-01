#
# $Id: find_options.rb 538 2010-08-23 00:19:46Z nicb $
#

module FindOptionHelper

  class FindOptions < Hash

    def <<(fo)
      k = fo.class.key
      self[k] = fo.class.find_option_group.new unless self.has_key?(k)
      self[k] << fo
    end

    def to_options
      result = self.class.superclass.new
      self.each_value { |v| result.update(v.to_option) }
      return result
    end

  end

end
