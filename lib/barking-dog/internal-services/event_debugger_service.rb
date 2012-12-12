module BarkingDog
  class EventDebuggerService
    include BarkingDog::BasicService

    def initialize
      subscribe(/.+/, :print_event)
    end

    def print_event(pattern, args)
      logger.debug "\nDEBUG EVENT: #{pattern} : #{args.inspect}\n"
    end

  end
end
