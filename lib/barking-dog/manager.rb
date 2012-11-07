module BarkingDog
  #{
  #    groups: {
  #        webapps: {
  #            webapp00: {
  #                address: webapp00.p.amicushq.com
  #            },
  #            webapp01: {
  #                address: webapp01.p.amicushq.com
  #            }
  #        }
  #    }
  #}

  class Manager
    include Celluloid

    attr_reader :config
    attr_reader :stopped
    attr_accessor :resource_groups
    def initialize(config = {})
      @config = Configuration.new(config)
      @stopped = false
      @resource_groups = Hashie::Mash.new
      act_on_configuration
      Celluloid::Actor[:manager] = actor
    end

    def act_on_configuration
      config.groups.each_pair do |name, resource_group_config|
        @resource_groups[name] = name.camlize.constantize.new(resource_group_config)
      end
    end

    def stop
      @stopped = true
    end



  end


end
