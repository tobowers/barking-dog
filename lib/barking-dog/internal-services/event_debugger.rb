module BarkingDog
  class EventDebugger

    def initialize
      subscribe(/.+/, :print_event)
    end

    def print_event(*args)
      puts args.inspect
    end

  end
end
