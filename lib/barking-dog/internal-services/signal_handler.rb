module BarkingDog
  class SignalHandler < BaseService

    def initialize
       Signal.trap("INT") do
         publish("barking-dog.termination_request")
       end
    end

  end
end
