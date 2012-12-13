module BarkingDog
  class CommandLineService
    include BarkingDog::BasicService
    on("command_line", :handle_command_line)

    def handle_command_line(pattern, event)
      logger.debug "command line received: #{event.payload.inspect}"
    end

  end
end
