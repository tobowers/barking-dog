require 'spec_helper'

describe BarkingDog::Resource do

  it "should take a name" do
    BarkingDog::Resource.new("test").name.should == "test"
  end

  describe "state changes" do
    before do
      @resource = BarkingDog::Resource.new("test")
    end

    it "should default to initializing" do
      @resource.state.should == :initializing
    end

    it "should transition to healthy" do
      @resource.healthy(Time.now)
      @resource.state.should == :healthy
    end

  end

end
