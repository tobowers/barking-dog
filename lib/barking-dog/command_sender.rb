module BarkingDog
  class CommandSender
    include BarkingDog::BasicService
    include Celluloid::ZMQ

    def initialize(address = nil)
      address ||= BarkingDog.resources.default_command_and_control_socket
      @socket = PubSocket.new

      begin
        @socket.connect(address)
      rescue IOError
        @socket.close
        raise
      end
    end

    def write(message)
      logger.debug("sending #{BarkingDog.resources.comand_and_control_topic} #{message}")
      @socket.send("#{BarkingDog.resources.comand_and_control_topic} #{message}")
    end

    def logger
      Celluloid::Logger
    end
  end
end
