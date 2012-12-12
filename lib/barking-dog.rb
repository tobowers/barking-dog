module BarkingDog
  # Your code goes here...
end

require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

require 'celluloid/zmq'
Celluloid::ZMQ.init

DEFAULT_COMMAND_AND_CONTROL_SOCKET = "ipc:///tmp/barking-dog"
COMMAND_AND_CONTROL_TOPIC = "barking-dog.command_and_control"

require 'barking-dog/base_service'
require 'barking-dog/event_publisher'
require 'barking-dog/command_sender'
require 'barking-dog/service_loader'

