module Parse
  module Op
    class AddUnique
      def initialize *objects
        @objects = objects
      end

      def to_json *args
        %Q|{"__op":"AddUnique","objects":#{@objects.inspect}}|
      end
    end
  end
end
