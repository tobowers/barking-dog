module BarkingDog

  class PoolProxy
    include BasicService

    attr_reader :pool
    def initialize(klass, pool_opts = {})
      @pool = klass.pool(pool_opts)
    end


  end

end
