require 'spec_helper'
require 'barking-dog/internal-services/command_and_control_service'

module BarkingDog
  describe CommandAndControlService do
    before do
      @command_and_control_service = CommandAndControlService.new
      @command_and_control_service.async.run

      @command_sender = CommandSender.new
      @receiver = GlobalEventReceiver.new
    end

    after do
      @receiver.terminate
      @command_sender.terminate
      @command_and_control_service.terminate
    end

    it "should publish barking-dog.termination_request on stop" do
      @future = @receiver.future.wait_for("barking-dog.termination_request")
      @command_sender.write("stop")
      @future.value(1).first.should == "barking-dog.termination_request"
    end

  end
end
