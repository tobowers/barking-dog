module BarkingDog
  module BasicService

    def self.included(klass)
      klass.class_attribute :internal_root_path
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
      #logger.debug "#{current_actor.class.name} is listening to: #{event_path(path)} with #{meth}"
      subscribe(event_path(path), meth)
    end

    def trigger(path, opts = {})
      #logger.debug "#{current_actor.class.name} is triggering: #{event_path(path)} with #{args.inspect}"
      path = event_path(path)
      publish_with_event(path, opts)
    end

    def event_path(path)
      if internal_root
        path = "#{internal_root}/#{path}"
      end
      if linked_service_loader?
        path = "#{root_event_path}/#{path}"
      end
      path
    end

    def root_trigger(path, opts = {})
      path = path_with_root(path)
      publish_with_event(path, opts)
    end

    def path_with_root(path)
      if linked_service_loader?
        path = "#{root_event_path}/#{path}"
      end
      path
    end

    def internal_root
      current_actor.class.internal_root_path || File.basename(current_actor.class.name.underscore)
    end

    def root_event_path
      linked_service_loader? ? linked_service_loader.root_event_path : nil
    end

  private

    def publish_with_event(path, opts = {})
      generated_by = Array(opts[:generated_by]).dup
      generated_by.unshift(path)
      async.publish(path, Event.new(path: path, payload: opts[:payload], generated_by: generated_by ))
    end

    def linked_service_loader?
      !!linked_service_loader
    end

    def linked_service_loader
      @linked_service_loader ||= current_actor.links.detect {|actor| actor.is_a?(ServiceLoader)}
    end

  end
end
