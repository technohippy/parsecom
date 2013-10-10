# coding:utf-8
module Parse
  class Pointer
    attr_reader :object

    def initialize parent, hash
      @parent_object = parent
      @raw_hash = hash

      if @raw_hash.has_key? 'body'
        @object = pointed_parse_class.new @raw_hash['body']
      end
    end

    def load
      unless @object
        @object = pointed_parse_class.find_by_id @raw_hash['objectId']
      end
      @object
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
