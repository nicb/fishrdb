#
# $Id: run.rb 551 2010-09-10 20:48:21Z nicb $
#

module Installer

  class Runner

    class << self

      include Installer::Lofi

      def install
        head
        bench = Benchmark.measure do
	        r = Rails.new(e = nil)
	        r.install
	
	        system("rake db:migrate RAILS_ENV=#{r.environment}")
	
	        link_lofi_to_nas
        end
        tail(bench.format("%.3r"))
      end

      def uninstall
        head('Uninstall')
        bench = Benchmark.measure do
	        r = Rails.new(e = nil)
	        r.uninstall

          unlink_lofi_to_nas
        end
        tail(bench.format("%.3r"), 'Uninstall')
      end

      LINE_SEPARATOR = '================================================='

      def head(tag = 'Install')
        tee(LINE_SEPARATOR) 
        tee("#{tag} started on #{Time.now}", '>>>> ')
      end

      def tail(time, tag = 'Install')
        tee("#{tag} completed on #{Time.now} (#{time} secs)", '>>>> ')
        tee(LINE_SEPARATOR) 
      end

    private

      def tee(msg, tagger = '')
        puts(msg)
        Installer::Logger.info(tagger + msg)
      end

    end

  end

end
