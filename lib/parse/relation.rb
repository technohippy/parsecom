# coding:utf-8
module Parse
  class Relation
    def initialize parent, column_name, hash
      @parent_object = parent
      @column_name = column_name
      @raw_hash = hash
    end

    def load parse_client=Parse::Client.default
      unless @objects
        pointer = @parent_object.pointer
        key = @column_name
        related_class = Parse::Object @raw_hash['className']
        @objects = related_class.find :where => proc {
          related_to key, pointer
        }
      end
      @objects
    end
  end
end
