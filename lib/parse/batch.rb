module Parse
  class Batch
    def initialize &block
      @blocks = []
      @blocks << block if block
    end

    def add_request &block
      @blocks << block if block
    end

    def run
      default_client = Parse::Client.default
      default_http_client = default_client.http_client
      batch_http_client = Parse::BatchHttpClient.new default_http_client.host
      default_client.http_client = batch_http_client
      begin
        @blocks.map &:call
      ensure
        default_client.http_client = default_http_client
      end

      default_client.call_api :post, 'batch', %Q|{"requests":#{batch_http_client.requests.to_json}}| do |responses|
        responses.each.with_index do |r, i|
          if after_block = batch_http_client.after_blocks[i]
            if r['success']
              after_block.call r['success']
            elsif r['error']
              # do something
              raise StandardError.new(r['error'].to_s)
            end
          end
        end
      end
    end
  end
end
