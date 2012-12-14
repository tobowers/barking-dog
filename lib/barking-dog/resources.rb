module BarkingDog
  class Resources

    def initialize
      @settings = {}
    end

    def configure(&block)
      block.call(self)
    end

    def clear
      @settings = {}
    end

    def method_missing(m, *args, &block)
      m = m.to_s.gsub('=','')
      @settings[m] = args[0] if args.size == 1
      @settings[m]
      # notice the new, I can now loose self in generators
      # @settings[m].to_s.camelize.constantize.new
    end
  end

end
