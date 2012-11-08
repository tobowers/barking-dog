require 'spec_helper'

describe BarkingDog::Check do

  before do
    @resource = BarkingDog::Resource.new("test")
    @check = BarkingDog::Check.new(@resource, {cool: true})
  end

  after do
    @resource.terminate
    @check.terminate
  end

  it "should #resource" do
    @check.resource.should == @resource
  end

  it "should Hashie::Mash the configuration" do
    @check.configuration.cool.should == true
  end

end
