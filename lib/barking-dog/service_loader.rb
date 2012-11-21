module BarkingDog
  INTERNAL_SERVICE_ROOT = File.expand_path(File.join(__FILE__, "..", "internal-services"))

  class ServiceLoader < Celluloid::SupervisionGroup
    include Celluloid::Notifications

    class_attribute :global_event_publisher
    self.global_event_publisher = GlobalEventPublisher.new

    #supervise MyActor, :as => :my_actor
    #supervise AnotherActor, :as => :another_actor, :args => [{:start_working_right_now => true}]
    #pool MyWorker, :as => :my_worker_pool, :size => 5

    def initialize
      super
      subscribe("barking-dog.termination_request", :handle_termination_request)
      subscribe("barking-dog.reload_request", :handle_reload_request)
      load_internal_services
      @terminated = false
    end

    def handle_termination_request(pattern, args)
      logger.debug "handling termination request: #{args.inspect}"
      self.class.global_event_publisher.terminate!
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
      Dir.glob("#{INTERNAL_SERVICE_ROOT}/*_service.rb") do |file_name|
        require file_name
        supervision_name = File.basename(file_name, ".*")
        begin
          class_name = "BarkingDog::#{supervision_name.camelize}".constantize
        rescue NameError => e
          Celluloid::Logger.error("expected #{file_name} to load #{class_name}")
          publish "barking-dog.termiation_request"
        end
        supervise_as supervision_name.to_sym, class_name
      end
    end

    def wait_for_terminated
      return true if @terminated
      wait :terminated
    end

    def logger
      Celluloid::Logger
    end


  end

end
