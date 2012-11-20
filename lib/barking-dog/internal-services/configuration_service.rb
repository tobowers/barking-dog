module BarkingDog
  class ConfigurationService < BaseService

    def initialize
      subscribe("barking-dog.new_configuration", :handle_new_configuration)
    end

    def handle_new_configuration(pattern, config)
      logger.debug("setting config to: #{config.inspect}")
      @configuration = config
      publish("barking-dog.new_configuration_saved", @configuration)
    end

    def configuration
      @configuration ||= {}
    end

  end
end
