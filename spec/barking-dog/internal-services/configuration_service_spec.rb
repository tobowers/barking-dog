require 'spec_helper'
require 'barking-dog/internal-services/configuration_service'

module BarkingDog
  describe ConfigurationService do
    let(:receiver) { GlobalEventReceiver.new }

    before do
      @publisher = GlobalEventPublisher.new
      @config_service = ConfigurationService.new
    end

    after do
      @publisher.terminate
      @config_service.terminate
      receiver.terminate
    end

    it "should set the event namespace at initialize" do
      new_config_service = ConfigurationService.new("custom.configuration")
      new_config_service.event_path.should == "custom.configuration"
      new_config_service.terminate
    end

    it "should have a default config" do
      @config_service.configuration.should == {}
      @config_service.event_path.should == ConfigurationService::DEFAULT_EVENT_PATH
    end

    describe "updating the config" do
      let(:event_name) { "barking-dog.configuration.saved" }
      let(:new_config) { {:foo => :bar} }

      before do
        @future = receiver.future.wait_for(event_name)
        @publisher.publish("barking-dog.configuration.new", new_config)
        @config_service.configuration.should == new_config
      end

      it "should update configs on events" do
        @config_service.configuration.should == new_config
      end

      it "should publish config changes" do
        val = @future.value(1)
        val.first.should == event_name
        val.last.should == [new_config]
      end

    end
  end


end
