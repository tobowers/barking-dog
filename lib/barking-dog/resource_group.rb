require 'debugger'

module BarkingDog
  class ResourceGroup
    include Celluloid

    class_attribute :check_period
    class_attribute :resource_class
    self.resource_class = BarkingDog::Resource

    attr_accessor :name
    attr_reader :resources, :configuration
    def initialize(name, config = {})
      @name = name
      @configuration = config
      @resources = []
      act_on_configuration
    end

    def act_on_configuration
      @configuration.each_pair do |name, resource_or_resource_config|
        resource = resource_from_resource_or_config((resource_or_resource_config || {}), name)
        add_resource(resource)
      end
    end

    def add_resource(resource)
      @resources << resource
    end

    def remove_resource(resource)
      @resources.delete(resource)
    end

    def add_resources(resources)
      resources.each {|r| add_resource(r)}
    end

    def remove_resources(resources)
      @resources.delete_if {|r| resources.include?(r) }
    end

    def resource_from_resource_or_config(resource_or_resource_config, name = nil)
      if resource_or_resource_config.is_a?(BarkingDog::Resource)
        resource_or_resource_config
      else
        resource_class.new(name, resource_or_resource_config)
      end
    end

  end


end
