module BarkingDog
  class ConfigurationService < BaseService

    DEFAULT_EVENT_PATH = "barking-dog.configuration"

    attr_reader :event_path
    def initialize(event_path =  DEFAULT_EVENT_PATH)
      @event_path = event_path
      subscribe("#{event_path}.new", :handle_new_configuration)
    end

    def handle_new_configuration(pattern, config)
      logger.debug("setting config to: #{config.inspect}")
      @configuration = config
      fire("saved", @configuration)
    end

    def configuration
      @configuration ||= {}
    end

    def fire(event, *payload)
      publish("#{event_path}.#{event}", payload)
    end

  end
end
