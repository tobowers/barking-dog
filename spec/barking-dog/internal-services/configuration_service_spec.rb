require 'spec_helper'
require 'barking-dog/internal-services/configuration_service'

module BarkingDog
  describe ConfigurationService do
    let(:receiver) { EventReceiver.new }

    before do
      @publisher = EventPublisher.new
      @config_service = ConfigurationService.create_isolated
    end

    after do
      @publisher.terminate
      @config_service.terminate
      receiver.terminate
    end

    it "should have a default config" do
      @config_service.configuration.should == {}
    end

    describe "updating the config" do
      let(:event_name) { "configuration_service/saved" }
      let(:event_name_with_root) { "#{BarkingDog.resources.root_event_path}/#{event_name}"}
      let(:new_config) { {:foo => :bar} }

      before do
        @future = receiver.future.wait_for(event_name)
        @publisher.trigger("configuration_service/new", payload: new_config)
      end

      it "should update configs on events" do
        val = @future.value(1)
        val.first.should == event_name_with_root
        @config_service.configuration.should == new_config
      end

      it "should publish config changes" do
        val = @future.value(1)
        val.first.should == event_name_with_root
        val.last.payload.should == new_config
      end

    end
  end


end
