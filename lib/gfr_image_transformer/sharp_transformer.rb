require "cgi"
require "base64"
require "json"

module GfrImageTransformer
  class SharpTransformer
    DEFAULT_RESIZER_MODE = :cover
    RESIZER_MODES = [:cover, :fill, :inside, :outside, :contain]

    attr_reader :image_url, :request_params, :width, :height, :metadata, :key

    def self.new(*args, &block)
      instance = super(*args)

      if block_given?
        instance.generate
      else
        instance
      end
    end

    def initialize(metadata, &block)
      @metadata = metadata
      @image_url = CGI.unescape(metadata.url)
      @request_params = {
        bucket: bucket_name,
        key: extract_key(image_url),
        edits: {},
      }

      if block_given?
        instance_eval(&block)
        generate
      end
    end

    ##
    # Resize image to width, height or width x height.
    # @param width [Integer] pixels wide the resultant image should be
    # @param height [Integer] pixels height the resultant image should be, use 0 to auto scale
    #
    def resize(width, height, options = {})
      resizer_mode = options.fetch(:resizer_mode) { DEFAULT_RESIZER_MODE }
      _width = width.to_i
      _height = height.to_i
      @width = _width.zero? ? nil : _width
      @height = _height.zero? ? nil : _height

      raise ArgumentError.new("invalid resizer mode `#{resizer_mode}``") if !RESIZER_MODES.include?(resizer_mode.to_sym)

      resize_params = {
        width: @width,
        height: @height,
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
      left = options.fetch(:left) { 0 }.to_i
      top = options.fetch(:top) { 0 }.to_i
      @width = width.to_i
      @height = height.to_i

      extract_params = {
        width: @width,
        height: @height,
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

    ##
    # Use these JPEG options for output image.
    # @param options [Hash] output options
    def jpeg(options = {})
      @request_params[:edits][:jpeg] = options
    end

    def toFormat(format_type, options = {})
      self
    end

    def generate
      encoded_request = Base64.encode64(request_params.to_json).gsub("\n", "")

      url = "#{domain}/#{encoded_request}"
      Variant.new(metadata: metadata, url: url, width: width, height: height)
    end

    private

    def bucket_name
      ENV.fetch("BUCKET_NAME")
    end

    def domain
      ENV.fetch("IMAGE_TRANSFORMER_DOMAIN")
    end

    def extract_key(image_url)
      if m = image_url.match(/#{bucket_name}.s3.amazonaws.com\/(.+)/)
        @key = m[1]
      elsif m = image_url.match(/s3.amazonaws.com\/#{bucket_name}\/(.+)/)
        @key = m[1]
      end
    end
  end
end
