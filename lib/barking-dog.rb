module BarkingDog
  # Your code goes here...
end

require 'celluloid/zmq'
Celluloid::ZMQ.init

require 'barking-dog/resource'
require 'barking-dog/version'
require 'barking-dog/server'

