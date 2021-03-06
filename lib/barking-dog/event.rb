module BarkingDog

  class Event

    def self.from_json(json)
      new(JSON.load(json).merge(without_append: true))
    end

    ATTRIBUTE_METHODS = [:version, :payload, :generated_at, :generated_by, :path, :target]

    attr_accessor *ATTRIBUTE_METHODS
    def initialize(opts)
      without_append = opts.delete(:without_append)

      @generated_at = Time.now.utc
      opts.each_pair do |key, value|
        self.send("#{key}=", value)
      end
      @generated_by ||= []
      @generated_by << path unless without_append
      self
    end

    # target isn't serializable - so we don't put it in here,
    # but it can be useful internally
    def to_hash(options = {})
      {
          version: version,
          payload: payload,
          generated_at: generated_at,
          generated_by: generated_by,
          path: path
      }
    end

    def to_json(options = {})
      JSON.dump(to_hash(options))
    end

    def ==(other)
      (ATTRIBUTE_METHODS - [:generated_at, :target]).inject(true) {|accum, method| accum && self.send(method) == other.send(method) }
    end

  end

end
