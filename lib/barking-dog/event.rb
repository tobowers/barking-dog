module BarkingDog
  class Event < Hashie::Mash

    def initialize(source_hash = nil, default = nil, &blk)
      self.timestamp = Time.now
      super
    end

  end
end
