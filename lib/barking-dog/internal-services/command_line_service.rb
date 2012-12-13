module BarkingDog
  class CommandLineService
    include BarkingDog::BasicService

    def initialize
      on("command_line", :handle_command_line)
    end

    def handle_command_line(pattern, event)
      logger.debug "command line received: #{event.payload.inspect}"
    end

  end
end
