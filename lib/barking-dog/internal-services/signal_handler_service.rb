module BarkingDog
  class SignalHandlerService < BaseService

    def initialize
       logger.debug("trapping INT signal")
       Signal.trap("INT") do
         publish("barking-dog.termination_request", :INT)
       end
    end

  end
end
