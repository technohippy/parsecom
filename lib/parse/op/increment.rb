module Parse
  module Op
    class Increment
      def initialize amount
        @amount = amount
      end

      def to_json *args
        %Q|{"__op":"Increment","amount":#{@amount}}|
      end
    end
  end
end
