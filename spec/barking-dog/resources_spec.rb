require 'spec_helper'

module BarkingDog
  describe Resources do
    let(:resources) { Resources.new }

    before do
      resources.configure do |config|
        config.something = "cool"
      end
    end

    it "should take settings" do
      resources.something.should == "cool"
    end

    it "should clear" do
      resources.clear
      resources.something.should be_nil
    end

    it "should each_pair" do
      spec_holder = {}
      resources.each_pair do |k,v|
        spec_holder[k] = v
      end
      spec_holder.should == {"something" => "cool"}
    end


  end

end
