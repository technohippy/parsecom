module Parse
  class Push
    ENDPOINT = 'push'

    attr_accessor :channels

    class <<self
      def send message_or_opts, opts={}, &block
        opts[:data] = message_or_opts if message_or_opts.is_a? String
        raise ArgumentError.new 'data is nil' unless opts[:data]
        opts[:push_time] = opts[:at] if opts[:at]
        opts[:where] = opts[:condition] if opts[:condition]

        push = Parse::Push.new opts[:data]
        push.at opts[:push_time] if opts[:push_time]
        if opts[:where]
          if opts[:where].is_a? Proc
            push.where &opts[:where]
          else
            push.where opts[:where]
          end
        end
        push.send &block
      end
    end

    def initialize data={}, parse_client=nil
      parse_client = data if data.is_a? Parse::Client
      data = {'alert' => data} if data.is_a? String

      @parse_client = parse_client || Parse::Client.default
      @channels = []
      @data = data 
      @query = nil
      @push_time = nil
    end

    def data= val
      @data = val.is_a?(String) ? {'alert' => val} : val
    end

    def where hash=nil, &block
      @query = Parse::Query.new 'Parse::Notification', @parse_client
      @query.where hash, &block
    end

    def push_time= val
      # TODO: refactoring: use ParseDate?
      @push_time = val.is_a?(Time) ? val.getutc.iso8601 : val
    end
    alias at push_time=

    def to_json
      raise ArgumentError.new '@data is nil' if @data.empty?

      json = {}
      json['channels'] = @channels unless @channels.empty?
      if @query
        where = @query.where
        def where.to_json *args; "{#{self.join ','}}" end
        json['where'] = where
      end
      json['push_time'] = @push_time if @push_time
      json['data'] = @data
      json.to_json
    end

    def send opt={}, &block
      push_time = opt[:push_time] || opt[:at] 
      self.push_time = push_time if push_time
      @parse_client.call_api :post, ENDPOINT, to_json, &block
    end
  end
end
