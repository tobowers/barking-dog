module BarkingDog
  class BaseService
    include Celluloid
    include Celluloid::Notifications

    def logger
      Celluloid::Logger
    end

  end
end
