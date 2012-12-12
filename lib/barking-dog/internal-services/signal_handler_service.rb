module BarkingDog
  class SignalHandlerService
    include BarkingDog::BasicService

    def initialize
       logger.debug("trapping INT signal")
       Signal.trap("INT") do
         publish("barking-dog.termination_request", :INT)
       end
    end

  end
end
