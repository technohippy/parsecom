# coding:utf-8
module Parse
  class User < Object

    class << self
      def sign_up username, password, hash={}
        self.new(username, password, hash).sign_up
      end
      
      def log_in username, password
        self.new(username, password).log_in
      end
    end

    def initialize username, password, hash={}
      super hash
      @username = username
      @password = password
    end

    def sign_up
      parse_client.sign_up @username, @password, opts do |resp_body|
        @obj_id = resp_body['objectId']
        @created_at = resp_body['createdAt']
        @raw_hash.update(@updated_hash).update resp_body
        @updated_hash.clear
        parse_client.session_token = resp_body['sessionToken']
        self
      end
    end

    def log_in
      parse_client.log_in @username, @password do |resp_body|
        @obj_id = resp_body['objectId']
        @created_at = resp_body['createdAt']
        @updated_at = resp_body['updatedAt']
        @raw_hash.update(@updated_hash).update resp_body
        @updated_hash.clear
        parse_client.session_token = resp_body['sessionToken']
        self
      end
    end

    def log_out
    end
  end
end
