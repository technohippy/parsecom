# coding:utf-8
module Parse
  RESERVED_EVENT_CLASS = {
    'AppOpened' => 'Parse::Event::AppOpened',
    'Error' => 'Parse::Event::Error'
  }

  class Event
    include Parse::Util

    @@event_class_vs_class_table = {}

    class << self
      attr_accessor :event_class_name, :parse_client

      def register_event_class event_class
        @@event_class_vs_class_table[event_class.event_class_name] = event_class
      end

      def create event_class_name, mod=::Object
        raise 'already defined' if mod.const_defined? event_class_name

        if RESERVED_EVENT_CLASS.has_key? event_class_name.to_s
          eval RESERVED_EVENT_CLASS[event_class_name.to_s]
        else
          klass = Class.new(Parse::Event)
          klass.event_class_name = event_class_name.to_sym
          mod.const_set event_class_name, klass
          register_event_class klass
        end
      end

      def event_class_name
        @event_class_name ||= name.split('::').last
      end

      def parse_client
        @parse_client ||= Parse::Client.default
      end

      def fire hash={}
        self.new(hash).fire
      end
    end

    attr_accessor :at, :dimensions

    def initialize hash={}
      hash = string_keyed_hash hash
      @at = hash.delete 'at'
      @at = Parse::Date.parse @at if @at.is_a?(String)
      @dimensions = hash.dup
    end

    def fire
      body = @dimensions
      body['at'] = @at if @at
      parse_client.call_api :post, "events/#{event_class_name}", body.to_json
    end

    def parse_client
      self.class.parse_client
    end

    def event_class_name
      self.class.event_class_name
    end
  end
end
