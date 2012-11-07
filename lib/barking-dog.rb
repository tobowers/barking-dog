module BarkingDog
  # Your code goes here...
end

require 'active_support/core_ext/class/attribute'
require 'active_support/core_ext/string/inflections'

require 'celluloid/zmq'
Celluloid::ZMQ.init

require 'barking-dog/configuration'
require 'barking-dog/event'
require 'barking-dog/check'
require 'barking-dog/resource'
require 'barking-dog/resource_group'
require 'barking-dog/manager'
require 'barking-dog/version'
require 'barking-dog/server'

