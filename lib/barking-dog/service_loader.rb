module BarkingDog
  INTERNAL_SERVICE_ROOT = File.expand_path(File.join(__FILE__, "..", "internal-services"))
  %w(command_line signal_handler event_debugger).each do |internal_service|
    require "#{INTERNAL_SERVICE_ROOT}/#{internal_service}.rb"
  end

  class ServiceLoader < Celluloid::SupervisionGroup
    include Celluloid::Notifications

    class_attribute :global_publisher
    self.global_event_publisher = GlobalEventPublisher.new

    supervise CommandLine, :as => :command_line_handler
    supervise EventDebugger, :as => :event_debugger
    supervise SignalHandler, :as => :signal_handler
    #supervise MyActor, :as => :my_actor
    #supervise AnotherActor, :as => :another_actor, :args => [{:start_working_right_now => true}]
    #pool MyWorker, :as => :my_worker_pool, :size => 5

    def initialize(additional_load_paths = [])
      #TODO: load additional files
      load_internal_services
      subscribe("barking-dog.termination_request", :handle_termination_request)
    end

    def handle_termination_request()
      puts 'handling termination request'
      self.class.global_event_publisher.terminate
      finalize
    end

    def load_internal_services

    end


  end

end
