#
# $Id: builder.rb 588 2010-12-23 15:44:27Z nicb $
#

builder_cwd = File.dirname(__FILE__)

require builder_cwd + '/csv/fis_reader'
require builder_cwd + '/pro_tools/old_data_aggregator'
require builder_cwd + '/tpw'

module Tdp
  
  module Builder

    class IntegratedTape

      attr_reader :content, :physical, :session

      def initialize(cont, phys, s)
        @content = cont
        @physical = phys
        @session = s
      end

    end

    class TapeFactory

      attr_reader :csv, :logger
      attr_accessor :integrated_tapes

      CWD = File.dirname(__FILE__) unless defined?(CWD)
      ROOT_DIR = CWD + '/../..' unless defined?(ROOT_DIR)
      SESSION_DIR = ROOT_DIR + '/public/private/session-notes/version-1' unless defined?(SESSION_DIR)
      LOG_DIR = ROOT_DIR + '/log' unless defined?(LOG_DIR)

      class << self

	      def find_tape_description(ti)
	        return Dir[SESSION_DIR + '/*/' + ti.tag + '/note.txt'].first
	      end

        def find_session_description(ti)
          return Dir[SESSION_DIR + '/*/' + ti.tag + '/' + ti.tag + '.txt'].first
        end

        def logfile_name
          env = ENV['RAILS_ENV'] || 'development'
          return LOG_DIR + "/tape_transfer.#{env}.log"
        end

      end

      def initialize(csvf)
        @csv = FisReader.new(csvf)
        @integrated_tapes = []
        logfile = TapeFactory.logfile_name
        File.unlink(logfile) if File.exists?(logfile)
        @logger = Logger.new(logfile, File::CREAT)
      end

    private

      def error_catcher(msg, error, &block)
        begin
          yield
        rescue
          error += 1
          logger.error(msg + ":\n#{$!}, from\n#{caller(3).join("\n")}")
        end
        return error
      end

    public

      def build
        csv.tape_items.each do
          |ti|
          tdp = self.class.find_tape_description(ti)
          pts = self.class.find_session_description(ti)
          if tdp && pts
            tdpc = ptsd = nil
            error = 0
            error = error_catcher("Tape Description Compilation for tape #{ti.tag} failed", error) do
              tdpo = Tdp::Tape::TapeParserWrapper.new(tdp)
              tdpc = tdpo.compile
            end
            error = error_catcher("ProTools Session parsing for tape #{ti.tag} failed", error) do
              ptsd = Tdp::ProTools::OldDataAggregator.new(pts)
              ptsd.parse
            end
            unless error > 0
              it = IntegratedTape.new(ti, tdpc, ptsd)
              logger.info("Integrated Tape Object for tape #{ti.tag} created.")
              integrated_tapes << it
            end
          else
            logger.error("Information for tape #{ti.tag} missing: Description = #{tdp}, Session = #{pts}")
          end
        end
      end

    end

  end

end
