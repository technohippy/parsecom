module Parse
  module Op
    class Remove
      def initialize *objects
        @objects = objects
      end

      def to_json *args
        %Q|{"__op":"Remove","objects":#{@objects.inspect}}|
      end
    end
  end
end
