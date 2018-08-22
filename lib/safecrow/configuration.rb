module Safecrow
  class Configuration

    # @api private
    attr_accessor :url, :apikey, :apisecret, :prefix

    def initialize
      @url = nil
      @apikey = nil
      @apisecret = nil
      @prefix = nil
    end
  end
end