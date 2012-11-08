require 'spec_helper'

describe BarkingDog::Resource do
  before do
    @resource =  BarkingDog::Resource.new("test")
  end

  after do
    @resource.terminate
  end

  it "should take a name" do
    @resource.name.should == "test"
  end

  describe "state changes" do

    it "should default to initializing" do
      @resource.state.should == :initializing
    end

    it "should transition to healthy" do
      @resource.healthy(Time.now)
      @resource.state.should == :healthy
    end

  end

end
