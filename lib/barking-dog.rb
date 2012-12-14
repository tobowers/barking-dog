require 'i18n'
require 'active_support/lazy_load_hooks'
require 'active_support/core_ext/string'
require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'
require 'celluloid/zmq'
Celluloid::ZMQ.init
require 'json'


require 'barking-dog/resources'

module BarkingDog
  #not threadsafe... do I care?
  def self.resources(&block)
    if block
      resource_instance.configure(&block)
    else
      resource_instance
    end
  end

  def self.resource_instance
    @resource_instance ||= BarkingDog::Resources.new
  end

end

BarkingDog.resources do |config|
  config.default_command_and_control_socket = "ipc:///tmp/barking-dog"
  config.comand_and_control_topic = "barking-dog.command_and_control"
end

COMMAND_AND_CONTROL_TOPIC =

require 'barking-dog/event'
require 'barking-dog/basic_service'
require 'barking-dog/pool_proxy'
require 'barking-dog/event_publisher'
require 'barking-dog/command_sender'
require 'barking-dog/service_loader'

