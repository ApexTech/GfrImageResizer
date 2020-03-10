require "cgi"
require "forwardable"

module GfrImageTransformer
  class Variations
    extend Forwardable

    attr_reader :metadata, :variants

    def_delegators :@variants, :[], :fetch, :keys
    def_delegators :metadata, :url, :width, :height

    def initialize(image_url, &block)
      @metadata = Metadata.new(CGI.unescape(image_url))

      @variants = {}

      if block_given?
        instance_eval(&block)
      end
    end

    def self.for(image_url, &block)
      new(image_url, &block)
    end

    def set_metadata(meta = {})
      metadata.width = meta[:width] || meta["width"]
      metadata.height = meta[:height] || meta["height"]
    end

    def variant(name, &block)
      @variants[name] = SharpTransformer.new(metadata, &block)
    end

    def method_missing(name, *args, &blk)
      if variants.key?(name)
        variants[name]
      else
        super
      end
    end

    def respond_to_missing?(method, include_private = false)
      super || @variants.key?(method)
    end
  end
end
