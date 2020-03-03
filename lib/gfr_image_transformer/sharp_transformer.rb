require "base64"
require "json"
require "uri"
require "open-uri"
require "image_size"

module GfrImageTransformer
  class SharpTransformer
    DEFAULT_RESIZER_MODE = :cover
    RESIZER_MODES = [:cover, :fill, :inside, :outside, :contain]

    attr_reader :image_url, :request_params

    def self.new(*args, &block)
      instance = super(*args)

      if block_given?
        instance.call
      else
        instance
      end
    end

    def initialize(image_url, &block)
      @image_url = image_url
      @request_params = {
        bucket: bucket_name,
        key: extract_key(image_url),
        edits: {},
      }

      if block_given?
        instance_eval(&block)
        call
      end
    end

    ##
    # Resize image to width, height or width x height.
    # @param width [Integer] pixels wide the resultant image should be
    # @param height [Integer] pixels height the resultant image should be, use 0 to auto scale
    #
    def resize(width, height, options = {})
      resizer_mode = options.fetch(:resizer_mode) { DEFAULT_RESIZER_MODE }
      raise ArgumentError.new("invalid resizer mode `#{resizer_mode}``") if !RESIZER_MODES.include?(resizer_mode.to_sym)

      resize_params = {
        width: width.zero? ? nil : width,
        height: height.zero? ? nil : height,
        fit: resizer_mode,
      }.compact

      @request_params[:edits][:resize] = resize_params
      self
    end

    ##
    # Extract a region of the image.
    # @param width [Integer] width of region to extract
    # @param height [Integer]  height of region to extract
    #
    def extract(width, height, options = {})
      left = options.fetch(:left) { 0 }
      top = options.fetch(:top) { 0 }

      extract_params = {
        width: width,
        height: height,
        left: left,
        top: top,
      }

      @request_params[:edits][:extract] = extract_params
      self
    end

    ##
    # Alternative spelling of normalise.
    # @param normalize [Boolean]
    #
    def normalize(normalize)
      @request_params[:edits][:normalize] = normalize
      self
    end

    ##
    # Sharpen the image.
    # @param sharpen [Boolean]
    #
    def sharpen(sharpen)
      @request_params[:edits][:sharpen] = sharpen
      self
    end

    def call
      encoded_request = Base64.encode64(request_params.to_json).gsub("\n", "")

      url = "#{domain}#{encoded_request}"
      Image.new(url: url, width: width, height: height)
    end

    private

    def width
      @request_params[:edits].fetch(:resize, {})[:width] || calculate_width
    end

    def height
      @request_params[:edits].fetch(:resize, {})[:height] || calculate_height
    end

    def calculate_width
      (image_size.width * height) / image_size.height
    end

    def calculate_height
      (image_size.height * width) / image_size.width
    end

    def bucket_name
      ENV.fetch("BUCKET_NAME")
    end

    def domain
      ENV.fetch("IMAGE_TRANSFORMER_DOMAIN")
    end

    def extract_key(image_url)
      index_key = image_url.index(bucket_name) + bucket_name.length + 1

      image_url[index_key..-1]
    end

    def image_size
      @image_size ||= URI.parse(image_url).open("rb") do |fh|
        ImageSize.new(fh)
      end
    end

    class Image < OpenStruct
    end
  end
end
