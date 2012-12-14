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
    path = "#{BarkingDog.resources.root_event_path}/#{pattern}"
    logger.debug "event receiver (spec) is waiting for #{path}"
    while !has_pattern?(path)
      sleep 0.001
    end
    logger.debug "event receiver (spec) received #{path}"
    events.detect {|e| e.first == path }
  end

  def has_pattern?(pattern)
    !!events.detect {|e| e.first == pattern }
  end

end
