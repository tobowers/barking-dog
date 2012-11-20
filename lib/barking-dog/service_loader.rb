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
      load_internal_services
    end

    def handle_termination_request(pattern, args)
      puts "handling termination request: #{args.inspect}"
      self.class.global_event_publisher.terminate!
      terminate
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


  end

end
