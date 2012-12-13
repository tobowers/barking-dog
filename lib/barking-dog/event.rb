module BarkingDog

  class Event

    ATTRIBUTE_METHODS = [:version, :payload, :generated_at, :generated_by, :path]

    attr_accessor *ATTRIBUTE_METHODS
    def initialize(opts)
      @generated_at = Time.now.utc
      opts.each_pair do |key, value|
        self.send("#{key}=", value)
      end
      @generated_by ||= []
      @generated_by << path
    end

    def to_hash
      {
          version: version,
          payload: payload,
          generated_at: generated_at,
          generated_by: generated_by,
          path: path
      }
    end

    def to_json
      JSON.dump(to_hash)
    end

    def ==(other)
      (ATTRIBUTE_METHODS - [:generated_at]).inject(true) {|accum, method| accum && self.send(method) == other.send(method) }
    end

  end

end
