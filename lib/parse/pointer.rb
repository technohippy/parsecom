# coding:utf-8
module Parse
  class Pointer
    attr_reader :object, :parse_object_id

    def initialize hash, parent=nil
      @raw_hash = hash
      @parse_object_id = hash['objectId']
      @parent_object = parent

      if @raw_hash.has_key? 'body'
        @object = pointed_parse_class.new @raw_hash['body']
      end
    end

    def load
      @object ||= pointed_parse_class.find_by_id @raw_hash['objectId']
    end

    def to_h
      {
        "__type" => "Pointer",
        "className" => "#{@raw_hash['className']}",
        "objectId" => "#{@raw_hash['objectId']}"
      }
    end

    def to_json *args
      to_h.to_json
    end

    private

    def pointed_parse_class
      included_parse_class_name = @raw_hash['className']
      mod = @parent_object.class.name.include?('::') ? \
        eval(@perent_object.class.name.split('::')[0..-2]) : ::Object
      Parse::Object included_parse_class_name, mod
    end
  end
end
