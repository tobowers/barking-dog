module BarkingDog
  class ConfigurationService
    include BarkingDog::BasicService

    attr_accessor :configuration
    def initialize
      @configuration ||= {}
      on("new", :handle_new_configuration)
    end

    def handle_new_configuration(pattern, event)
      #logger.debug("setting config to: #{event.payload.inspect}")
      #debugger
      @configuration = event.payload
      trigger("saved", payload: @configuration)
    end

  end
end
