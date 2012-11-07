require 'spec_helper'

describe BarkingDog::Configuration do
  let(:subject) { BarkingDog::Configuration.new }

  it "should be a mash" do
    subject.something = true
    subject[:something] = true
  end

  it "should be a mash with indifferent access" do
    subject['test'] = true
    subject[:test].should == true
  end

  it "should initialize with another hash" do
    BarkingDog::Configuration.new({test:true })[:test].should == true
  end


end
