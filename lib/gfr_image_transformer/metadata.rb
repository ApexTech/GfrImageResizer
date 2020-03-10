
module GfrImageTransformer
  class Metadata
    attr_reader :url
    attr_writer :width, :height

    def initialize(url, width = nil, height = nil)
      @url = url
      @width = width
      @height = height
    end

    def width
      @width ||= image_size.width
    end

    def height
      @height ||= image_size.height
    end

    def to_h
      {
        url: url,
        width: width,
        height: height,
      }
    end

    private

    def image_size
      @image_size ||= URI.parse(URI.encode(url)).open("rb") do |fh|
        ImageSize.new(fh)
      end
    end
  end
end
