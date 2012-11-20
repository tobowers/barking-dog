module BarkingDog
  class CommandLineService < BaseService

    def initialize(*args)
      puts args.inspect
      subscribe("barking-dog.command_line", :handle_command_line)
    end

    def handle_command_line(pattern, args)
      puts "command line received: #{args.inspect}"
    end

  end
end
