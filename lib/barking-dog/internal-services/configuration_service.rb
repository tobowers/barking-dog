module BarkingDog
  class ConfigurationService
    include BarkingDog::BasicService

    def initialize
      on("new", :handle_new_configuration)
    end

    def handle_new_configuration(pattern, config)
      logger.debug("setting config to: #{config.inspect}")
      @configuration = config
      trigger("saved", @configuration)
    end

    def configuration
      @configuration ||= {}
    end

  end
end
