module BarkingDog
  class SignalHandler < BaseService

    def initialize
       Signal.trap("INT") do
         publish("barking-dog.termination_request", :INT)
       end
    end

  end
end
