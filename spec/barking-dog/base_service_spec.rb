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


  end
end
