require 'hashie'

module BarkingDog
  class Check
    include Celluloid

    attr_reader :resource, :configuration
    def initialize(resource, configuration = {})
      @resource = resource
      @configuration = Hashie::Mash.new(configuration)
      #define in your subclass?
    end

  end

end
