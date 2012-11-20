module BarkingDog
  # Your code goes here...
end

require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

require 'celluloid/zmq'
Celluloid::ZMQ.init

require 'barking-dog/base_service'
require 'barking-dog/global_event_publisher'
require 'barking-dog/service_loader'

