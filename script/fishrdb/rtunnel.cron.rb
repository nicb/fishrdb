#!/usr/bin/env ruby
#
# $Id: rtunnel.cron.rb 593 2010-12-25 20:27:48Z nicb $
#
# This uses the rtunnel client application as an external process
#
# This uses the rtunnel and the sys-proctable gems
#
# It checks whether the tunnels contained in the config file provided are up,
# and if they are not it starts them.
#
#
require 'rubygems'
require 'rtunnel'

require 'yaml'

class RtunnelHandler

	attr_reader :from_port, :to_address, :connect_server, :tunnel_timeout,
    :pid_file
  attr_accessor :rtunnel_client
	
  DEFAULT_CONNECT_SERVER = 'ssh.sme-ccppd.org'
  RTUNNEL_APPLICATION = 'rtunnel_client'
  ENV_COMMAND = '/usr/bin/env'
  RTUNNEL_CLIENT_COMMAND = "#{RTUNNEL_APPLICATION}"
  PGREP_COMMAND = 'pgrep'
  RTUNNEL_LOG_LEVEL = 'ERROR'
  DEFAULT_RTUNNEL_TIMEOUT = 10.0
  DEFAULT_PID_PATH = File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'pids')
  DEFAULT_SLEEP_TIME = 3.0


  class ConfigurationMissing < StandardError; end
  class MandatoryArgumentMissing < StandardError; end
  class SystemCallFailed < StandardError; end

  def initialize(config) #, key = DEFAULT_PRIVATE_KEY_FILE)
    raise(ConfigurationMissing) unless config
    ['from_port', 'to_address'].each { |arg| raise(MandatoryArgumentMissing, "#{arg}") unless config.has_key?(arg) }
    @from_port = config['from_port'].to_s
    @to_address = config['to_address'].to_s
    @connect_server = config.has_key?('connect_server') ? config['connect_server'] : DEFAULT_CONNECT_SERVER
    @tunnel_timeout = config.has_key?('tunnel_timeout') ? config['tunnel_timeout'] : DEFAULT_RTUNNEL_TIMEOUT
    @pid_file = File.join(DEFAULT_PID_PATH, "rtunnel.#{self.connect_server}:#{self.from_port}.pid")
  end

  def alive?
    File.exists?(self.pid_file)
  end

  def connect
    start_tunnel unless alive?
  end

private

	def start_tunnel
	  opts = {
      :control_address => self.connect_server,
      :log_level => RTUNNEL_LOG_LEVEL,
      :tunnel_timeout => self.tunnel_timeout,
      :remote_listen_address => self.from_port,
      :tunnel_to_address => self.to_address,
    }
   rtun_process = Process.fork do
      at_exit { halt_client }
      self.rtunnel_client = RTunnel::Client.new(opts)
      EventMachine::run { self.rtunnel_client.start }
    end
    create_pid_file(rtun_process)
    sleep(DEFAULT_SLEEP_TIME)
	end

  def create_pid_file(pid)
    File.open(self.pid_file, 'w') { |fh| fh.write(pid) }
  end

  def remove_pid_file
    File.unlink(self.pid_file)
  end

  def halt_client
    remove_pid_file
  end

end

class RtunnelContainer

  attr_reader :config_file, :rtunnels

  RTUNNEL_DEFAULT_CONFIG_FILE = File.join(File.dirname(__FILE__), '..', '..', 'config', 'rtunnels.yml')

  def initialize(c_f = RTUNNEL_DEFAULT_CONFIG_FILE)
    @config_file = c_f
    @rtunnels = read_config_file(self.config_file)
  end

  def check_tunnels_and_start_them_if_necessary
    self.rtunnels.each { |rt| rt.connect }
  end

private

  def read_config_file(config_file)
    result = []
    hash = YAML.load(File.open(config_file, 'r'))
    hash.values.each do
      |config|
      result << RtunnelHandler.new(config)
    end
    result
  end

end

rtc = RtunnelContainer.new
rtc.check_tunnels_and_start_them_if_necessary

exit(0)
