module Parse
  module Op
    class Add
      def initialize *objects
        @objects = objects
      end

      def to_json *args
        %Q|{"__op":"Add","objects":#{@objects.inspect}}|
      end
    end
  end
end
