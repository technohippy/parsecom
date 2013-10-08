# coding:utf-8
module Parse
  class Client
    API_SERVER = 'api.parse.com'
    API_VERSION = 1
    @@default_client = nil

    attr_accessor :http_client, :session_token, :master_key

    def self.default_client
      @@default_client ||= new
    end

    def initialize application_id=nil, api_key=nil, master_key=nil, http_client=nil
      @application_id = application_id || Parse.application_id
      @api_key = api_key || Parse.api_key
      @master_key = master_key || Parse.master_key
      if @application_id.nil? || @api_key.nil?
        raise ArgumentError.new <<-EOS.gsub(/^ +/)
          Both Application ID and API Key must be set.
          ex. Parse.credentials application_id: APPLICATION_ID, api_key: API_KEY
        EOS
      end
      @http_client = http_client || Parse::HttpClient.new(API_SERVER)
    end

    def call_api method, endpoint, body=nil, opt_headers={}, &block
      endpoint = "/#{API_VERSION}/#{endpoint}" unless endpoint[0] == '/'
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
        'User-Agemt' => 'A parse.com client for ruby'
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

    def find parse_class, object_id_or_conditions, opts={}
      if object_id_or_conditions.is_a? String
        find_by_id parse_class, object_id_or_conditions, opts
      elsif object_id_or_conditions.is_a? Hash
        find_by_query parse_class, object_id_or_conditions
      end
    end

    def find_by_id parse_class, object_id, opts={}
      call_api :get, "classes/#{parse_class.parse_class_name}/#{object_id}" do |resp_body|
        convert parse_class, resp_body

        if opts.has_key? :include
          included_keys = opts[:include]
          included_keys = [included_keys] unless included_keys.is_a? Enumerable
          included_keys.each do |included_key|
            pointer = resp_body[included_key]
            pointer.load
          end
        end

        parse_class.new resp_body
      end
    end

    def find_by_query parse_class, conditions
      query = Query.new parse_class
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

    def create parse_object, values
      call_api :post, "classes/#{parse_object.parse_class_name}", values.to_json do |resp_body|
        resp_body
      end
    end

    def update parse_object, values
      call_api :put, "classes/#{parse_object.parse_class_name}/#{parse_object.parse_object_id}", values.to_json do |resp_body|
        resp_body
      end
    end

    def delete parse_object
      call_api :delete, "classes/#{parse_object.parse_class_name}/#{parse_object.parse_object_id}" do |resp_body|
        resp_body
      end
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
      ret = block.call
      @use_master_key = tmp
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

    private

    def convert parse_class, resp_body
      resp_body.each do |k, v|
        if v.is_a?(Hash) && v.has_key?('__type')
          resp_body[k] = case v['__type']
            when 'Date'
              Date.parse v['iso']
            when 'File'
              Parse::File.new v
            when 'Pointer'
              # TODO: too many arguments
              Parse::Pointer.new self, parse_class, resp_body, k, v
            else
              v
            end
        end
      end
    end
  end
end
