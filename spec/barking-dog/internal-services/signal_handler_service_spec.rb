require 'spec_helper'
require 'barking-dog/internal-services/signal_handler_service'

module BarkingDog

  describe SignalHandlerService do
    before do
      @receiver = EventReceiver.new
      @signal_handler = SignalHandlerService.new
    end

    after do
      @receiver.terminate
      @signal_handler.terminate
    end

    it "should publish barking-dog.termination_request on INT" do
      pending "how do you test a signal handling?"
      pid = Process.pid
      Process.kill("TERM", pid)
      @receiver.events.detect {|e| e.first == "barking-dog.termination_request"}.should_not be_nil
    end


  end

end
