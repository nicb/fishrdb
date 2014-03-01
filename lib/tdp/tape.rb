#
# $Id: tape.rb 502 2010-05-30 20:56:50Z nicb $
#

pwd = File.dirname(__FILE__)
$: << pwd <<  pwd + '/tape/'

require 'box/display'
require 'box/note'
require 'box/mapper'
require 'calligraphy_description'
require 'session_description'
require 'tape_content'
require 'tape_description'

require 'tdp.tab'
require 'tcp.tab'
require 'tbp.tab'

module Tdp

  module Tape

	  class Item
	    attr_accessor :session, :description, :content, :box
	
	    def filename
	      return description.tag
	    end
	
	  end

  end

end
