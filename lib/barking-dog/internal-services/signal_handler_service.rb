module BarkingDog
  class SignalHandlerService
    include BarkingDog::BasicService

    def initialize
       logger.debug("trapping INT signal")
       Signal.trap("INT") do
         root_trigger("termination_request", payload: :INT)
       end
    end

  end
end
