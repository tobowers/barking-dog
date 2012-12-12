require 'spec_helper'

module BarkingDog

  describe ServiceLoader do

    before(:all) do
      class BaseService
        include BarkingDog::BasicService
      end
    end

    before do
      #have the block called
      @service_loader = BarkingDog::ServiceLoader.run!
      @event_receiver = EventReceiver.new
    end

    after do
      @event_receiver.terminate
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

    describe "#change_root_event_path" do
      before do
        @service_loader.root_event_path.should == ServiceLoader.root_event_path
        @service_loader.change_root_event_path("other-dog")
      end

      it "should set the root event path" do
        @service_loader.root_event_path.should == "other-dog"
      end

      it "should only keep subscriptions for the new ones" do
        @service_loader.subscriptions.length.should == 3
      end

      it "should not respond to the old events" do
        event_publisher = EventPublisher.new
        event_publisher.root_trigger("barking-dog.debug_request")
        @event_receiver.future.wait_for("barking-dog.debug_request").value(1) #wait for the async event

        has_service?(EventDebuggerService).should be_false
      end

    end

    describe "#turn_on_event_debugger" do

      it "should turn_on_event_debugger" do
        @service_loader.turn_on_event_debugger
        has_service?(EventDebuggerService).should be_true
      end

      it "should respond to the debugging event" do
        @service_loader.event_publisher.trigger("debug_request")
        @event_receiver.future.wait_for("barking-dog.debug_request").value(1) #wait for the async event
        has_service?(EventDebuggerService).should be_true
      end

    end

    def has_service?(klass)
      !!@service_loader.actors.detect {|m| m.class == klass}
    end
  end

end
