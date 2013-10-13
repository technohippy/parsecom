module Parse
  module Op
    class AddRelation
      def initialize *pointers
        @pointers = pointers
      end

      def to_json *args
        %Q|{"__op":"AddRelation","objects":[#{@pointers.map(&:to_json).join(',')}]}|
      end
    end
  end
end
