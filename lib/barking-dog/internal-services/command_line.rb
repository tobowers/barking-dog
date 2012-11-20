module BarkingDog
  class CommandLine < BaseService

    def initialize(*args)
      puts args.inspect
      subscribe("barking-dog.command_line", :handle_command_line)
    end

    def handle_command_line(argv)
      puts "command line received: #{argv}"
    end

  end
end
