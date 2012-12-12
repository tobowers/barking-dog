INTERNAL_SERVICE_ROOT = File.expand_path(File.join(__FILE__, "..", "internal-services"))

%w(command_and_control command_line configuration signal_handler event_debugger).each do |base_service_name|
  file_name = File.join(INTERNAL_SERVICE_ROOT, "#{base_service_name}_service.rb")
  require file_name
end

module BarkingDog

  class ServiceLoader < Celluloid::SupervisionGroup
    include Celluloid::Notifications

    class_attribute :root_event_path
    self.root_event_path = "barking-dog"

    #supervise MyActor, :as => :my_actor
    #supervise AnotherActor, :as => :another_actor, :args => [{:start_working_right_now => true}]
    #pool MyWorker, :as => :my_worker_pool, :size => 5

    attr_reader :registry, :event_publisher
    attr_accessor :root_event_path, :subscriptions
    def initialize
      @subscriptions = []
      @root_event_path = self.class.root_event_path
      super
      @event_publisher = add_service(EventPublisher)
      subscribe_to_events
      load_internal_services
      @terminated = false
    end

    def subscribe_to_events
      on("termination_request", :handle_termination_request)
      on("reload_request", :handle_reload_request)
      on("debug_request", :turn_on_event_debugger)
    end

    # here we dup the old subs, and subscribe to the new ones
    # so that there's never a time when we're not listening
    # to any
    def change_root_event_path(event_path)
      old_subs = subscriptions.dup
      self.root_event_path = event_path
      subscribe_to_events
      old_subs.each do |sub|
        unsubscribe(sub)
      end
      self.subscriptions = subscriptions - old_subs
    end

    def handle_termination_request(pattern, args)
      logger.debug "handling termination request: #{args.inspect}"
      terminate
    end

    def terminate
      @terminated = true
      signal :terminated
      super
    end

    def handle_reload_request(pattern, file_name)
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

    def load_internal_services
      [CommandAndControlService, CommandLineService, ConfigurationService, SignalHandlerService].each do |klass|
        add_service(klass)
      end
    end

    def turn_on_event_debugger(pattern=nil) #can be fired by an event handler
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
      subscriptions << subscribe(event_path(path), meth)
    end

    def trigger(path, *args)
      publish(event_path(path), *args)
    end

    def add_service(klass, *args, &block)
      registry_name = klass.name.underscore.to_sym
      member = supervise_as registry_name, klass, *args, &block
      if member.actor.respond_to?(:run)
        member.actor.async.run
      end
      member.actor
    end


  private
    def event_path(path)
      "#{root_event_path}.#{path}"
    end

  end

end
