require 'spec_helper'

module BarkingDog
  describe BaseService do

    before do
      @base = BaseService.new
    end

    after do
      @base.terminate
    end

    it "should be a publisher and receiver" do
      @base.respond_to?(:publish).should be_true
      @base.respond_to?(:subscribe).should be_true
    end


  end
end
