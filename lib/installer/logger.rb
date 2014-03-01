#
# $Id: logger.rb 551 2010-09-10 20:48:21Z nicb $
#

require 'fishrdb_test_logger'

module Installer

  class Logger < FishrdbTestLogger

    OUTPUT_FILE = File.join(Rails::RAILS_ROOT, 'log', 'install.log')

    @@logger ||= Installer::Logger.new(Logger::INFO, OUTPUT_FILE)

	  class <<self
	
      def create_methods
		    %w(fatal error warn info debug).each do
		      |method|
		      class_eval("def self.#{method}(msg); return @@logger.#{method}(msg); end")
		    end
      end
	
	  end

    create_methods

  end

end
