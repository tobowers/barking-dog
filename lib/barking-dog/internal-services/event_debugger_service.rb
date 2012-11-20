module BarkingDog
  class EventDebuggerService < BaseService

    def initialize
      subscribe(/.+/, :print_event)
    end

    def print_event(pattern, args)
      logger.debug "\nDEBUG EVENT: #{pattern} : #{args.inspect}\n"
    end

  end
end
