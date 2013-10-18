# coding:utf-8
module Parse
  class Relation
    def initialize parent, column_name, hash
      @parent_object = parent
      @column_name = column_name
      @raw_hash = hash
      @added_pointers = []
      @removed_pointers = []
    end

    def add item
      unless @removed_pointers.empty?
        raise ArgumentError.new('Please save for removed items before adding')
      end
      item = item.pointer if item.is_a?(Parse::Object)
      @added_pointers.push item
    end

    def remove item
      unless @added_pointers.empty?
        raise ArgumentError.new('Please save for added items before removing')
      end
      item = item.pointer if item.is_a?(Parse::Object)
      @removed_pointers.push item
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

    def changed?
      (@added_pointers.size + @removed_pointers.size) != 0
    end

    def to_h
      if not @added_pointers.empty?
        {
          "__op" => "AddRelation",
          "objects" => @added_pointers.map(&:to_h)
        }
      elsif not @removed_pointers.empty?
        {
          "__op" => "RemoveRelation",
          "objects" => @removed_pointers.map(&:to_h)
        }
      else
        {
          "__op" => "AddRelation",
          "objects" => [nil]
        }
      end
    end

    def to_json *args
p to_h
      to_h.to_json
    end
  end
end
