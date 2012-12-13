require 'barking-dog'

class PooledClass
  include Celluloid
  include Celluloid::Notifications

  def initialize
    logger.debug("initialized an instance #{current_actor.object_id}")
    subscribe("hi", :handle_event)
  end

  def do_nothing
    logger.debug("do nothing: #{current_actor.object_id}")
  end

  def handle_event(pattern, *args)
    logger.debug("#{current_actor.object_id} received #{pattern}, #{args.inspect}")
  end

  def logger
    Celluloid::Logger
  end

end

# well shit, this doesn't work as expected

publisher = BarkingDog::EventPublisher.new

pool = PooledClass.pool(:size => 15)

futures = []
15.times do
  futures << pool.future.do_nothing
end

publisher.trigger("hi", payload: :cool)




