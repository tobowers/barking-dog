module BarkingDog
  class Resource
    include Celluloid

    class Machine
      include Celluloid::FSM

      default_state :initializing

      state :initializing, :to => :healthy do
        puts "transitioned to healthy"
      end

      state :healthy, :to => [:unhealthy] do
        puts "transitioned from healthy to unhealthy"
      end

      state :done
    end

    attr_accessor :name
    attr_reader :machine
    def initialize(name)
      @name = name
      @machine = Machine.new
    end

    def state
      machine.state
    end

    def healthy(timestamp = Time.now)
      machine.transition :healthy
    end


  end
end
