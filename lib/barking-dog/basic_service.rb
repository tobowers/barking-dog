module BarkingDog
  module BasicService

    module ClassMethods
      def event_hash
        @event_hash ||= {}
      end

      def on(evt, meth, opts = {})
        event_hash[evt] = {method: meth, options: opts}
      end

      def create_isolated(*args, &block)
        service = new(*args, &block)
        service.subscribe_to_class_events
        service
      end

    end

    def self.included(klass)
      klass.class_attribute :internal_root_path
      klass.class_attribute :concurrency
      klass.extend(ClassMethods)
      klass.send(:include, Celluloid)
      klass.send(:include, Celluloid::Notifications)
    end

    def logger
      Celluloid::Logger
    end

    def ping
      "pong"
    end

    def on(path, meth)
      logger.debug "#on called on #{actor_name}"
      logger.debug "#{current_actor.class.name} is listening to: #{event_path(path)} with #{meth}"
      subscribe(path, meth)
    end

    def trigger(path, opts = {})
      logger.debug "#{current_actor.class.name} is triggering: #{event_path(path)} with #{opts.inspect}"
      path = event_path(path)
      publish_with_event(path, opts)
    end

    def event_path(path)
      logger.debug("event path for #{path} on #{current_actor}")
      if internal_root
        path = "#{internal_root}/#{path}"
      end
      if root_event_path
        path = "#{root_event_path}/#{path}"
      end
      path
    end

    def root_trigger(path, opts = {})
      logger.debug "#{current_actor.class.name} is root_triggering: #{path_with_root(path)} with #{opts.inspect}"
      path = path_with_root(path)
      publish_with_event(path, opts)
    end

    def path_with_root(path)
      if root_event_path
        path = "#{root_event_path}/#{path}"
      end
      path
    end

    def internal_root
      current_actor.class.internal_root_path || File.basename(current_actor.class.name.underscore)
    end

    def root_event_path
      @root_event_path
    end

    def root_event_path=(str)
      @root_event_path = str
    end

    def subscribe_to_class_events
      current_actor.class.event_hash.each_pair do |pattern, method_and_options|
        current_actor.on(pattern, method_and_options[:method])
      end
      current_actor
    end

    def event_from_options(path, opts)
      generated_by = Array(opts[:generated_by]).dup
      generated_by.unshift(path)
      Event.new(path: path, payload: opts[:payload], generated_by: generated_by )
    end

  private

    def actor_name
      current_actor.class.name
    end

    def publish_with_event(path, opts = {})
      async.publish(path, event_from_options(path, opts))
    end

  end
end
