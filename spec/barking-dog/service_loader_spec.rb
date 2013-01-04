require 'spec_helper'

module BarkingDog

  describe ServiceLoader do

    before do
      class BaseService
        include BarkingDog::BasicService
        class ExpectedTestError < StandardError; end
        on "base_service/test_event", :handle_test_event

        class_attribute :handled
        self.handled = Queue.new

        def handle_test_event(path, evt)
          logger.debug "base service received: #{path} with #{evt.inspect}"
          self.class.handled << [path, evt]

          if evt.payload == "RAISE"
            logger.debug "raising because of a RAISE payload in BaseService"
            raise ExpectedTestError, evt.inspect
          end
        end

      end
    end

    before do
      #have the block called
      @service_loader = BarkingDog::ServiceLoader.run!
      @event_receiver = EventReceiver.new
    end

    after do
      @event_receiver.terminate
      @service_loader.async.trigger("termination_request", payload: :SPEC)
      if @service_loader.alive?
        future = @service_loader.future.wait_for_terminated
        future.value(2)
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

    describe "independent services" do

      let(:base_service) { @service_loader.add_service(BaseService) }

      before do
        base_service #just call it to add the service
      end

      after do
        base_service.terminate
      end

      it "should add services" do
        base_service.ping.should == "pong"
      end

      describe "when erroring" do
        before do
          base_service.trigger("test_event", payload: "RAISE")
        end

        it "should not get added to the handled" do
          BaseService.handled.pop.last.payload.should == "RAISE"
        end

      end


    end


    describe "#root_event_path=" do
      before do
        @service_loader.root_event_path.should == BarkingDog.resources.root_event_path
        @service_loader.root_event_path = "other-dog"
      end

      it "should set the root event path" do
        @service_loader.root_event_path.should == "other-dog"
      end

      it "should only keep subscriptions for the new ones" do
        @service_loader.subscriptions.length.should == 3
      end

    end

    describe "#turn_on_event_debugger" do

      it "should turn_on_event_debugger" do
        @service_loader.turn_on_event_debugger
        has_service?(EventDebuggerService).should be_true
      end

      it "should respond to the debugging event" do
        @service_loader.trigger("debug_request")
        @event_receiver.future.wait_for("debug_request").value(1) #wait for the async event
        has_service?(EventDebuggerService).should be_true
      end

    end

    def has_service?(klass)
      !!@service_loader.actors.detect {|m| m.class == klass}
    end
  end

end
