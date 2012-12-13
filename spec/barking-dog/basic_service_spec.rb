require 'spec_helper'

module BarkingDog
  describe BasicService do

    before do
      class BaseService
        include BasicService
        on "cool_stuff", :handle_cool_stuff
        class_attribute :cool_stuff_receiver
        self.cool_stuff_receiver = Queue.new


        def handle_cool_stuff(*args)
          self.class.cool_stuff_receiver << args
        end
      end
      BaseService.cool_stuff_receiver.length.should == 0
    end

    let(:base_service) { BaseService.new }

    before do
      base_service #spin up the base_service instance
    end

    after do
      base_service.terminate
    end

    describe "class level event handlers" do
      let(:event_receiver) { EventReceiver.new }
      let(:event_future) { event_receiver.future.wait_for("cool_stuff") }
      let(:publisher) { EventPublisher.new }

      after do
        event_receiver.terminate
        publisher.terminate
      end

      it "should set the class event hash" do
        BaseService.event_hash.should == {"cool_stuff" => {method: :handle_cool_stuff, options: {}}}
      end

      it "should subscribe to the events when create_isolated" do
        future = event_future
        base_service = BaseService.create_isolated
        publisher.trigger("cool_stuff")
        future.value(1)[0].should == "cool_stuff"
        base_service.terminate
        BaseService.cool_stuff_receiver.length.should == 1
      end
    end

    it "should be a publisher and receiver" do
      base_service.respond_to?(:on).should be_true
      base_service.respond_to?(:trigger).should be_true
    end

    it "should publish to its class" do
      base_service.event_path("test").should == "base_service/test"
    end

    it "should have a class concurrency attribute" do
      BaseService.concurrency = 2
      BaseService.concurrency.should == 2
    end

    describe "when part of a service loader" do
      let(:expected_root) { "barking-dog" }

      before do
        @service_loader = ServiceLoader.run!
        @base_service = @service_loader.add_service(BaseService)
        @service_loader.root_event_path.should == expected_root
      end

      after do
        #@service_loader.terminate
        @service_loader.async.trigger("termination_request", payload: :SPEC)
        if @service_loader.alive?
          future = @service_loader.future.wait_for_terminated
          future.value(5)
        end
      end

      it "should set the root_event_path to the service loaders base event path" do
        @base_service.root_event_path.should == expected_root
      end

      it "should publish to its root and class" do
        @base_service.event_path("test").should == "#{expected_root}/base_service/test"
      end



    end

    def logger
      Celluloid::Logger
    end


  end
end
