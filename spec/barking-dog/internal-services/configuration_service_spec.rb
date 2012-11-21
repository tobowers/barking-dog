require 'spec_helper'
require 'barking-dog/internal-services/configuration_service'

module BarkingDog
  describe ConfigurationService do
    before do
      @publisher = GlobalEventPublisher.new
      @config_service = ConfigurationService.new
    end

    after do
      @publisher.terminate
      @config_service.terminate
    end

    it "should have a default config" do
      @config_service.configuration.should == {}
    end

    it "should update configs on events" do
      @publisher.publish("barking-dog.new_configuration", {:foo => :bar})
      @config_service.configuration.should == {:foo => :bar}
    end

  end


end
