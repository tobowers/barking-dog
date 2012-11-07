module BarkingDog
  class Check
    include Celluloid

    attr_reader :resource
    def initialize(resource)
      @resource = resource
      #define in your subclass?
    end

  end

end
