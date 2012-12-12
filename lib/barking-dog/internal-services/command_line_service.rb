module BarkingDog
  class CommandLineService
    include BarkingDog::BasicService

    def initialize
      subscribe("barking-dog.command_line", :handle_command_line)
    end

    def handle_command_line(pattern, args)
      logger.debug "command line received: #{args.inspect}"
    end

  end
end
