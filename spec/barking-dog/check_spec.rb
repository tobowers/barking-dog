require 'spec_helper'

describe BarkingDog::Check do

  before do
    @resource = BarkingDog::Resource.new("test")
    @check = BarkingDog::Check.new(@resource)
  end

  it "should save the resource" do
    @check.resource.should == @resource
  end

end
