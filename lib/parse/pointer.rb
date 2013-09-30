# coding:utf-8
module Parse
  class Pointer
    def initialize parse_client, parent_parse_class, parent_hash, parent_key, hash
      @parse_client = parse_client
      @parent_parse_class = parent_parse_class
      @parent_hash = parent_hash
      @parent_key = parent_key
      @raw_hash = hash
    end

    def load &block
      included_parse_class_name = @raw_hash['className']
      mod = @parent_parse_class.name.include?('::') ? \
        eval(@perent_parse_class.name.split('::')[0..-2]) : ::Object
      included_parse_class = Parse::Object included_parse_class_name, mod
      @parent_hash[@parent_key] = @parse_client.find(
        included_parse_class, @raw_hash['objectId']).tap do |real_value|
        if block
          block.call real_value
        end
      end
    end
  end
end
