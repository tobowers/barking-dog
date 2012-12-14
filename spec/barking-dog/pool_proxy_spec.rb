require 'spec_helper'

module BarkingDog

  describe PoolProxy do

    before do
      class BaseConcurrentService
        include BarkingDog::BasicService
        self.concurrency = 2

        on "cool", :handle_cool

        class_attribute :cool_handler
        self.cool_handler = Queue.new

        def handle_cool(_, evt)
          self.class.cool_handler << evt
        end

      end

      BaseConcurrentService.cool_handler.length.should == 0
    end

    let(:event_publisher) { EventPublisher.new }
    let(:event_receiver) { EventReceiver.new }
    let(:event_future) { event_receiver.future.wait_for("cool") }

    let(:pool_proxy) { PoolProxy.new(BaseConcurrentService, size: 2) }

    after do
      pool_proxy.terminate
      event_publisher.terminate
    end

    before do
      event_future #calling to setup the future
      pool_proxy.subscribe_to_class_events
    end

    it "should proxy events to the pool" do
      event_publisher.trigger("cool")
      event_future.value(1)[0].should == "barking-dog/cool"
      BaseConcurrentService.cool_handler.length.should == 1
    end

  end

end
