module Parse
  class BatchHttpClient < HttpClient
    attr_accessor :requests, :after_blocks

    def initialize host
      @host = host
      @requests = []
      @after_blocks = []
    end

    def request method, endpoint, headers={}, body=nil, &block
      raise 'find cannot be in a batch request.' if method.to_s.upcase == 'GET'

      @after_blocks << block
      @requests << {
        "method" => method.to_s.upcase,
        "path" => endpoint,
        "body" => JSON.parse(body) # TODO: ??
      }
    end
  end
end
