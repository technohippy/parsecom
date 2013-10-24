# encoding:utf-8
module Parse
  class ParseDate
    include Util

    class <<self
      def parse str
        new :iso => str
      end
    end

    def initialize hash={}
      hash = string_keyed_hash hash
      @raw_hash = hash
      @time = ::Time.parse hash['iso'] if hash.has_key? 'iso'
    end

    def to_h
      {
        "__type" => "Date",
        "iso" => @time.strftime('%Y-%m-%dT%H:%M:%SZ')
      }
    end

    def to_json *args
      to_h.to_json
    end

    def to_s
      to_json
    end

    def method_missing name, *args, &block
      @time.__send__ name, *args, &block
    end
  end
end
