require "uri"
require "open-uri"
require "image_size"

module GfrImageTransformer
  class Variant
    attr_reader :url, :metadata

    def initialize(metadata:, url:, width:, height:)
      @metadata = metadata
      @url = url
      @width = width
      @height = height
    end

    def calculate_metadata
      {
        width: width,
        height: height,
      }
    end

    def width
      @width || calculate_width
    end

    def height
      @height || calculate_height
    end

    def transformer
      SharpTransformer
    end

    private

    def calculate_width
      (metadata.width * height) / metadata.height
    end

    def calculate_height
      (metadata.height * width) / metadata.width
    end
  end
end
