require 'spec_helper'

module BarkingDog
  describe BaseService do

    let(:base_service) { BaseService.new }

    before do
      base_service = BaseService.new
    end

    after do
      base_service.terminate
    end

    it "should be a publisher and receiver" do
      base_service.respond_to?(:publish).should be_true
      base_service.respond_to?(:subscribe).should be_true
    end

    it "should publish to its class" do
      base_service.event_path("test").should == "base_service.test"
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
        @service_loader.async.trigger("termination_request", :SPEC)
        if @service_loader.alive?
          future = @service_loader.future.wait_for_terminated
          future.value(5)
        end
      end

      it "should set the root_event_path to the service loaders base event path" do
        @base_service.root_event_path.should == expected_root
      end

      it "should publish to its root and class" do
        @base_service.event_path("test").should == "#{expected_root}.base_service.test"
      end



    end

    def logger
      Celluloid::Logger
    end


  end
end
