module GfrImageTransformer
  class Variations
    attr_reader :key, :variants

    def initialize(key, &block)
      @key = key
      @variants = {}

      if block_given?
        instance_eval(&block)
        @variants
      end
    end

    def self.for(key, &block)
      new(key, &block).variants
    end

    def variant(name, &block)
      @variants[name] = SharpTransformer.new(key, &block)
    end
  end
end
