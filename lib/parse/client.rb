# coding:utf-8
module Parse
  class Client
    API_SERVER = 'api.parse.com'
    API_VERSION = 1
    @@default_client = nil

    attr_accessor :http_client, :session_token, :master_key

    def self.default
      @@default_client ||= new
    end

    def self.default= default_client
      @@default_client = default_client
    end

    def initialize application_id=nil, api_key=nil, master_key=nil, http_client=nil
      @application_id = application_id || Parse.application_id
      @api_key = api_key || Parse.api_key
      @master_key = master_key || Parse.master_key
      if @application_id.nil? || @api_key.nil?
        raise ArgumentError.new <<-EOS.gsub(/^ +/, '')
          Both Application ID and API Key must be set.
          ex. Parse.credentials application_id: APPLICATION_ID, api_key: API_KEY
        EOS
      end
      @http_client = http_client || Parse::HttpClient.new(API_SERVER)
    end

    def canonical_endpoint endpoint
      case endpoint
      when %r|/#{API_VERSION}/classes/_User|
        endpoint.sub %r|/#{API_VERSION}/classes/_User|, "/#{API_VERSION}/users"
      when %r|/#{API_VERSION}/classes/_Role|
        endpoint.sub %r|/#{API_VERSION}/classes/_Role|, "/#{API_VERSION}/roles"
      else
        endpoint
      end
    end

    def call_api method, endpoint, body=nil, opt_headers={}, &block
      endpoint = "/#{API_VERSION}/#{endpoint}" unless endpoint[0] == '/'
      endpoint = canonical_endpoint endpoint
      headers = build_headers opt_headers
      if body.is_a?(Hash)
        body = Hash[*(body.to_a.map{|k, v| [k, URI.encode(v)]}.flatten)].to_json 
      end
      @http_client.request method, endpoint, headers, body, &block
    end

    def build_headers opt_headers={}
      headers = {
        'X-Parse-Application-Id' => @application_id,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'User-Agent' => 'A parse.com client for ruby'
      }
      if @use_master_key
        headers['X-Parse-Master-Key'] = @master_key
      else
        headers['X-Parse-REST-API-Key'] = @api_key
      end
      headers['X-Parse-Session-Token'] = @session_token if @session_token
      headers.update opt_headers
    end

    def sign_up username, password, opts={}, &block
      call_api :post, 'users', {'username' => username, 'password' => password}.update(opts || {}), &block
    end

    def log_in username, password, &block
      call_api :get, "login?username=#{URI.encode username}&password=#{
        URI.encode password}", nil, &block
    end

    def log_out
      @session_token = nil
    end

    def find parse_class_name, object_id_or_conditions, opts={}
      case object_id_or_conditions
      when :all
        find_by_query parse_class_name, opts
      when String, Symbol
        find_by_id parse_class_name, object_id_or_conditions, opts
      when Hash
        find_by_query parse_class_name, object_id_or_conditions
      else
        raise ArgumentError.new('the first argument should be a string, a symbol, or a hash.')
      end
    end

    def find_by_id parse_class_name, object_id, opts={}
      call_api :get, "classes/#{parse_class_name}/#{object_id}" do |resp_body|
        if opts.has_key? :include
          included_keys = [opts[:include]].flatten
          included_keys.each do |included_key|
            resp_body[included_key].tap do |pointer|
              if pointer['__type'] == 'Pointer'
                pointer['body'] = self.find_by_id pointer['className'], pointer['objectId']
              else
                raise ArgumentError.new('included column should be a pointer.')
              end
            end
          end
        end
        resp_body
      end
    end

    def find_by_query parse_class_name, conditions
      query = Query.new parse_class_name, self
      query.limit conditions[:limit] if conditions.has_key? :limit
      query.skip conditions[:skip] if conditions.has_key? :skip
      query.count conditions[:count] if conditions.has_key? :count
      if conditions.has_key? :order
        order = conditions[:order]
        order = [order] unless order.is_a? Array
        query.order order
      end
      if conditions.has_key? :keys
        keys = conditions[:keys]
        keys = [keys] unless keys.is_a? Array
        query.keys keys
      end
      if conditions.has_key? :include
        include = conditions[:include]
        include = [include] unless include.is_a? Array
        query.include include
      end
      if conditions.has_key? :where
        case condition = conditions[:where]
        when Hash
          query.where condition
        when Proc
          query.where condition
        else
          raise 'wrong condition'
        end
      end
      query.invoke
    end

    def create parse_class_name, values, &block
      call_api :post, "classes/#{parse_class_name}", values.to_json, &block
    end

    def update parse_class_name, parse_object_id, values, &block
      call_api :put, "classes/#{parse_class_name}/#{parse_object_id}", values.to_json, &block
    end

    def delete parse_class_name, parse_object_id, &block
      call_api :delete, "classes/#{parse_class_name}/#{parse_object_id}", &block
    end

    def call_function name, param
      func_name = Parse.auto_snake_case ? name.to_s.gsub(/_([a-z])/) {$1.upcase} : name
      call_api :post, "functions/#{func_name}", param.to_json do |resp_body|
        if resp_body.has_key? 'result'
          resp_body['result']
        else
          raise StandartError.new 'unknown error'
        end
      end
    end

    def use_master_key!
      self.use_master_key = true
    end

    def use_master_key= val
      raise ArgumentError.new('master_key is not set.') if val && !@master_key
      @use_master_key = val
    end

    def use_master_key &block
      return @use_master_key unless block

      tmp, @use_master_key = @use_master_key, true
      begin
        ret = block.call
      ensure
        @use_master_key = tmp
      end
      ret
    end

    %w(find find_by_id find_by_query create update delete call_function).each do |name|
      eval <<-EOS
        def #{name}! *args, &block
          use_master_key do
            #{name} *args, &block
          end
        end
      EOS
    end

    def method_missing name, *args, &block
      call_function name, args.first
    end
  end
end
