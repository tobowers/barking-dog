require 'spec_helper'
require 'json'

module BarkingDog

  describe Event do
    let(:event_path) { "cool_beans/cool" }
    let(:event) { Event.new(path: event_path) }

    it "should set the generated_at at creation" do
      event.generated_at.should be_a(Time)
    end

    it "should save the path" do
      event.path.should == event_path
    end

    it "should to_hash" do
      event.to_hash[:path].should == event_path
    end

    it "should to_json" do
      JSON.load(event.to_json)['path'].should == event_path
    end
  end

end
