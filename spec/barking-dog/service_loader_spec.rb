require 'spec_helper'

module BarkingDog

  describe ServiceLoader do

    before do
      #have the block called
      @service_loader = BarkingDog::ServiceLoader.run!
    end

    after do
      #@service_loader.terminate
      @service_loader.async.trigger("termination_request", :SPEC)
      if @service_loader.alive?
        future = @service_loader.future.wait_for_terminated
        future.value(5)
      end
    end

    it "should load internal services" do
      [CommandLineService, CommandAndControlService, ConfigurationService,SignalHandlerService].each do |internal_service|
        has_service?(internal_service).should be_true
      end
    end

    it "should add them to the registry" do
      @service_loader.registry[:"barking_dog/command_and_control_service"].ping.should == "pong"
    end

    it "should add services" do
      base_service = @service_loader.add_service(BaseService)
      base_service.ping.should == "pong"
    end

    describe "#turn_on_event_debugger" do

      before do
        @receiver = EventReceiver.new
      end

      after do
        @receiver.terminate
      end

      it "should turn_on_event_debugger" do
        @service_loader.turn_on_event_debugger
        has_service?(EventDebuggerService).should be_true
      end

      it "should respond to the debugging event" do
        @service_loader.event_publisher.trigger("debug_request")
        @receiver.future.wait_for("barking-dog.debug_request").value(1) #wait for the async event
        has_service?(EventDebuggerService).should be_true
      end

    end

    def has_service?(klass)
      !!@service_loader.actors.detect {|m| m.class == klass}
    end




  end

end
