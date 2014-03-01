#
# $Id: base.rb 572 2010-12-12 18:37:32Z nicb $
#

module BundleGenerator

  class Base

    attr_reader :shouter

    def initialize(s = nil)
      @shouter = s ? s : Driver.shouter
    end

    def dot
      self.shouter.say('.')
    end

  end

end
