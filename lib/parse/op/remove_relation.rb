module Parse
  module Op
    class RemoveRelation
      def initialize *pointers
        @pointers = pointers
      end

      def to_json *args
        %Q|{"__op":"RemoveRelation","objects":[#{@pointers.map(&:to_json).join(',')}]}|
      end
    end
  end
end
