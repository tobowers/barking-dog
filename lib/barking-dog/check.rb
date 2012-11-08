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

    def do_check_with_event_return
      result = do_check
      pass_or_fail = result[0]
      BarkingDog::Event.new(result[1].merge({
          :passed => pass_or_fail,
          :checker => Celluloid::Actor.current,
          :resource => resource,
      }))
    end

    def do_check_with_callback(callback_object)
      callback_object.async.check_report_handler(do_check_with_event_return)
    end

  end

end
