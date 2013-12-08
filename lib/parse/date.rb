# encoding:utf-8
module Parse
  class ParseDate
    include Util

    class <<self
      def parse *args
        if args.size == 1 && args.first.is_a?(String)
          new :iso => args.first
        else
          new.tap do |dt|
            dt.time = Time.gm *args
          end
        end
      end
    end

    attr_accessor :time

    def initialize hash={}
      hash = string_keyed_hash hash
      @raw_hash = hash
      @time = ::Time.parse hash['iso'] if hash.has_key? 'iso'
    end

    def <=> other
      self.time <=> other.time
    end

    def to_h
      {
        "__type" => "Date",
        "iso" => @time.iso8601
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

  module_function

  def date *args
    ParseDate.parse *args
  end
end
