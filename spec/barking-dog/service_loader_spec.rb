require 'spec_helper'

module BarkingDog

  describe ServiceLoader do

    before(:all) do
      #have the block called
      @service_loader = BarkingDog::ServiceLoader.run!
    end

    after(:all) do
      #@service_loader.terminate
      @service_loader.async.publish("barking-dog.termination_request", :SPEC)
      if @service_loader.alive?
        future = @service_loader.future.wait_for_terminated
        future.value(5)
      end
    end

    it "should load internal services" do
      [CommandLineService, CommandAndControlService, ConfigurationService,EventDebuggerService,SignalHandlerService].each do |internal_service|
        @service_loader.actors.detect {|m| m.class == internal_service}.should_not be_nil
      end
    end

    it "should add them to the registry" do
      @service_loader.registry[:"barking_dog/command_and_control_service"].ping.should == "pong"
    end


  end

end
