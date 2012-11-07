require 'spec_helper'

describe BarkingDog::Event do

  let(:subject) { BarkingDog::Event.new }

   it "should be a mash" do
     subject.something = true
     subject[:something] = true
   end

   it "should be a mash with indifferent access" do
     subject['test'] = true
     subject[:test].should == true
   end

   it "should initialize with another hash" do
     BarkingDog::Event.new({test:true })[:test].should == true
   end

   it "should add a timestamp to the event" do
     subject.timestamp.should be_a(Time)
   end

end
