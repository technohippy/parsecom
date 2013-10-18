# coding:utf-8
module Parse
  class Role < Object
    class << self
      def parse_class_name
        '_Role'
      end
    end

    def initialize hash
      super

      #set_column 'roles', RoleItemArray.new(Parse::Role)
      #set_column 'users', RoleItemArray.new(Parse::User)
      set_column 'roles', Parse::Relation.new(self, 'roles', {'className' => '_Role'})
      set_column 'users', Parse::Relation.new(self, 'users', {'className' => '_User'})
    end

    class RoleItemArray < Array
      def initialize klass
        @klass = klass
      end

      def add item
        push \
          case item
          when String, Symbol
            @klass.new('objectId' => item).pointer
          when @klass
            item.pointer
          when Pointer
            super
          else
            raise ArgumentError.new("wrong type: #{item.class.name}")
          end
      end

      def to_h
        {
          "__op" => "AddRelation",
          "objects" => map {|r| JSON.parse(r.to_json)}
        }
      end

      def to_json *args
        to_h.to_json
      end
    end
  end
end
