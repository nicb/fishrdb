#
# $Id: session_description.rb 494 2010-05-02 03:39:44Z nicb $
#
require 'date'
require 'tape_description'

module Tdp

  module Tape

		class SessionDescription
		  attr_accessor :date, :location, :transferrers
		
		  def initialize
		    @date = nil
		    @location = ''
		    @transferrers = []
		  end
		
		  def date=(string)
		    (d, m, y) = string.split('/')
		    @date = Date.civil(y.to_i, m.to_i, d.to_i)
		  end

      class << self

      private

	      TRANSFERRER_MAP = 
	      {
	        'Bernardini' => 'Bernardini, Nicola',
	        'Quaresima' => 'Quaresima, Bruno',
	        'Cursi' => 'Cursi, Carlo',
	        'Schiavoni' => 'Schiavoni, Piero',
	        'Gianni' => 'Gianni, Stefania',
	      }

      public
	
	      def map_transferrer(name)
	        return TRANSFERRER_MAP[name]
	      end

      end
		
		end

  end

end
