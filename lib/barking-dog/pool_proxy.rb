module BarkingDog

  class PoolProxy
    include BasicService

    attr_accessor :subscribers
    attr_reader :pool, :klass
    def initialize(klass, pool_opts = {})
      @klass = klass
      @pool = klass.pool_link(pool_opts)
      @subscribers = []
    end

    def setup_listeners
      logger.debug("setting up listeners")
      klass.event_hash.each_pair do |path, method_and_options|
        logger.debug("subscribing to #{path}")
        subscribers << notifier.subscribe(pool, path, method_and_options[:method])
      end
    end

    #overwrite internal root so it is the passed in klass instead of the pool proxy
    def internal_root
      klass.internal_root_path || File.basename(klass.name.underscore)
    end

    def notifier
      Celluloid::Notifications.notifier
    end

  end

end
