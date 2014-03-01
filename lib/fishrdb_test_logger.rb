#
# $Id: fishrdb_test_logger.rb 551 2010-09-10 20:48:21Z nicb $
#

class FishrdbTestLogger < ActiveSupport::BufferedLogger

  TEST_LOGGER_LEVELS =
  {
    Logger::DEBUG => "DEBUG",
    Logger::INFO  => "INFO",
    Logger::WARN  => "WARN",
    Logger::ERROR => "ERROR",
    Logger::FATAL => "FATAL",
  }

  TEST_LOGGER_DEFAULT_LOGFILE = File.dirname(__FILE__) + '/../log/test.log'
  TAG_REGEXP = Regexp.compile(/^>+ /)

  def initialize(l = Logger::DEBUG, logfile = TEST_LOGGER_DEFAULT_LOGFILE)
    super(logfile)
    self.level = l
    return self
  end

  def add(severity, msg = nil, pname = nil, &block)
    message = (msg || (block && block.call) || pname).to_s
    level = TEST_LOGGER_LEVELS[severity] || 'UKNOWN'

    message = format(level, message)

    return super(severity, message, pname)
  end

private

  def format(l, msg)
    result = msg

    if msg =~ TAG_REGEXP
      result = msg.sub(TAG_REGEXP,'')
      result = "[%-6s %s %6s] %s" % [l + ':',
                                     Time.now.strftime("%d/%m %H:%M:%S"),
                                     '#' + $$.to_s,
                                     result]
    end

    return result
  end

end
