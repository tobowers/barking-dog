#this isn't great, uses a spin lock - but it's a spec helper
class EventReceiver
  include BarkingDog::BasicService

  attr_accessor :events
  def initialize
    @events = []
    subscribe(/.+/, :store_and_signal_events)
  end

  def store_and_signal_events(*args)
    @events << args
  end

  def wait_for(pattern)
    while !has_pattern?(pattern)
      sleep 0.001
    end
    events.detect {|e| e.first == pattern }
  end

  def has_pattern?(pattern)
    !!events.detect {|e| e.first == pattern }
  end

end
