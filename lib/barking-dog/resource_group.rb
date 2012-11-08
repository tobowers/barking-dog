require 'debugger'

module BarkingDog
  class ResourceGroup
    include Celluloid

    class_attribute :check_period
    class_attribute :resource_class
    self.resource_class = BarkingDog::Resource

    attr_accessor :name
    attr_reader :resources, :configuration, :checks, :stopped
    def initialize(name, config = {})
      @name = name
      @configuration = config
      @configuration[:resources] ||= {}
      @resources = []
      @checks = {}
      @stopped = false
      act_on_configuration
    end

    def stop
      @stopped = true
    end

    def act_on_configuration
      @configuration[:resources].each_pair do |name, resource_or_resource_config|
        resource = resource_from_resource_or_config((resource_or_resource_config || {}), name)
        add_resource(resource)
      end
      Array(@configuration[:checks]).each do |check_or_check_config|
        add_check_from_check_or_config(check_or_check_config)
      end
    end

    def add_check(check, opts = {})
      @checks[check] = opts
    end

    def remove_check(check)
      @checks.delete(check)
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
        resource_class.new_link(name, resource_or_resource_config)
      end
    end

    def add_check_from_check_or_config(check_or_check_config, name = nil)
      if check_or_check_config.is_a?(Class) and (check_or_check_config < BarkingDog::Check) #is subclass of?
          add_check(check_or_check_config)
      elsif check_or_check_config.is_a?(Symbol)
          add_check(check_or_check_config.to_s.camelize.constantize)
      else #assume hash-like
        add_check(check_or_check_config[:name].to_s.camelize.constantize, check_or_check_config[:options])
      end
    end

  end


end
