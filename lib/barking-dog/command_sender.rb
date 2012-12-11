module BarkingDog
  class CommandSender < BaseService
    include Celluloid::ZMQ

    def initialize(address = DEFAULT_COMMAND_AND_CONTROL_SOCKET)
      @socket = PubSocket.new

      begin
        @socket.connect(address)
      rescue IOError
        @socket.close
        raise
      end
    end

    def write(message)
      logger.debug("sending #{COMMAND_AND_CONTROL_TOPIC} #{message}")
      @socket.send("#{COMMAND_AND_CONTROL_TOPIC} #{message}")
    end

    def logger
      Celluloid::Logger
    end
  end
end
