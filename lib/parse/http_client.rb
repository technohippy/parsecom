# coding:utf-8
module Parse
  class HttpClient
    def initialize host
      @host = host
    end

    def request method, endpoint, headers={}, body=nil, &block
      req = eval("Net::HTTP::#{method.to_s.capitalize}").new endpoint, headers
      req.body = body if body
      client = Net::HTTP.new @host, 443
      #client.set_debug_output $stderr
      client.use_ssl = true
      client.start do
        resp = client.request req
        resp_body = JSON.parse resp.body
        raise StandardError.new "error calling #{endpoint}: #{
          resp_body['error']}" if resp_body.has_key? 'error'
        block.call resp_body if block
      end
    end
  end
end
