# coding:utf-8
module Parse
  class HttpClient
    attr_accessor :host, :dry_run

    def initialize host
      @host = host
      @dry_run = false
    end

    def dry_run?
      !!@dry_run
    end

    def dry_run!
      @dry_run = true
    end

    def request method, endpoint, headers={}, body=nil, &block
      if dry_run
        $stderr.puts "#{
          method} #{endpoint}\n#{
          headers.to_a.map{|k,v| "#{k}: #{v}"}.join "\n"
          }\n\n#{
          body}"
        block.call({}) if block
        return
      end

      req = eval("Net::HTTP::#{method.to_s.capitalize}").new endpoint, headers
      req.body = body if body
      client = Net::HTTP.new @host, 443
      client.set_debug_output $stderr if $DEBUG
      client.use_ssl = true
      client.start do
        # TODO
        resp = client.request req
        resp_body = resp.body.empty? ? nil : JSON.parse(resp.body)
        raise StandardError.new "error calling #{endpoint}: #{
          resp_body['error']}" if resp_body.is_a?(Hash) && resp_body.has_key?('error')
        block.call resp_body if block
      end
    end
  end
end
