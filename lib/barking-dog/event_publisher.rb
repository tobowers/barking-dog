module BarkingDog
  class EventPublisher < BaseService

    def trigger(*args, &block)
      #always root trigger from here
      root_trigger(*args, &block)
    end

  end
end
