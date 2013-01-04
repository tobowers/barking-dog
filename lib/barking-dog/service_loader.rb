INTERNAL_SERVICE_ROOT = File.expand_path(File.join(__FILE__, "..", "internal-services"))

%w(command_and_control command_line configuration signal_handler event_debugger).each do |base_service_name|
  file_name = File.join(INTERNAL_SERVICE_ROOT, "#{base_service_name}_service.rb")
  require file_name
end

module BarkingDog

  class ServiceLoader < Celluloid::SupervisionGroup
    include Celluloid::Notifications

    trap_exit :crash_logger
    #supervise MyActor, :as => :my_actor
    #supervise AnotherActor, :as => :another_actor, :args => [{:start_working_right_now => true}]
    #pool MyWorker, :as => :my_worker_pool, :size => 5

    attr_reader :registry, :event_publisher
    attr_accessor :subscriptions
    def initialize
      @subscriptions = []
      super
      @event_publisher = add_service(EventPublisher)
      subscribe_to_events
      load_internal_services
      @terminated = false
    end

    def subscribe_to_events
      on("termination_request", :termination_request)
      on("reload_request", :handle_reload_request)
      on("debug_request", :turn_on_event_debugger)
    end

    # here we dup the old subs, and subscribe to the new ones
    # so that there's never a time when we're not listening
    # to any
    def root_event_path=(event_path)
      old_subs = subscriptions.dup
      BarkingDog.resources.root_event_path = event_path
      subscribe_to_events
      old_subs.each do |sub|
        unsubscribe(sub)
      end
      self.subscriptions = subscriptions - old_subs
    end

    def root_event_path
      BarkingDog.resources.root_event_path
    end

    def termination_request(*args)
      logger.debug "handling termination request: #{args.inspect}"
      terminate
    end

    def terminate
      @terminated = true
      signal :terminated
      super
    end

    def load_internal_services
      [CommandAndControlService, CommandLineService, ConfigurationService, SignalHandlerService].each do |klass|
        add_service(klass)
      end
    end

    def turn_on_event_debugger(_=nil,_=nil) #can be fired by an event handler
      add_service(EventDebuggerService)
    end

    def wait_for_terminated
      return true if @terminated
      wait :terminated
    end

    def logger
      Celluloid::Logger
    end

    def on(path, meth)
      subscriptions << subscribe(event_path_with_root(path), meth)
    end

    def add_service(klass, *args, &block)
      member = if klass.concurrency
                 add_concurrent_service(klass, *args, &block)
               else
                 add_single_actor_service(klass, *args, &block)
               end
      actor = member.actor
      subscribe_actor(actor)
      actor
    end

    def add_single_actor_service(klass, *args, &block)
      member = supervise_as registry_name_for(klass), klass, *args, &block
      if member.actor.respond_to?(:run)
        member.actor.async.run
      end
      member
    end

    def add_concurrent_service(klass, *args, &block)
      class_for_loader = PoolProxy
      args = {args: [klass, args: args, size: klass.concurrency], }
      add(class_for_loader, :args => args, :block => block, :as => registry_name_for(klass))
    end

    def subscribe_actor(actor)
      actor.subscribe_to_class_events
    end

    def event_path_with_root(path)
      "#{root_event_path}/#{path}"
    end

    def trigger(*args, &block)
      event_publisher.trigger(*args, &block)
    end

    def registry_name_for(klass)
      klass.name.underscore.to_sym
    end

    def has_concurrent_option?(klass)
      klass.respond_to?(:concurrency) and klass.concurrency
    end

    # this thing isn't really tested
    def handle_reload_request(pattern, evt)
      file_name = evt.payload
      logger.debug("#{pattern}: #{file_name}")
      supervision_name = File.basename(file_name, ".*")
      logger.debug("supervision name: #{supervision_name}")
      actor = @registry[supervision_name.to_sym]
      logger.debug("found actor")
      actor_class = actor.class
      logger.debug('terminating actor')
      actor.terminate
      logger.debug("using ruby 'load' on #{file_name}")
      load file_name
      logger.debug('setting up supervision again')
      supervise_as supervision_name.to_sym, actor_class
    end

    def crash_logger(actor, reason)
      logger.debug("crash from service loader: #{actor.inspect}, for reason: #{reason.inspect}")
    end

  end

end
