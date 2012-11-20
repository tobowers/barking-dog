module BarkingDog
  class EventDebugger < BaseService

    def initialize
      subscribe(/.+/, :print_event)
    end

    def print_event(pattern, args)
      puts "\nDEBUG EVENT: #{pattern} : #{args.inspect}\n"
    end

  end
end
