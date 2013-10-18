module Parse
  module Op
    class AddRelation
      def initialize *pointers
        @pointers = pointers.map do |p|
          if p.is_a? Parse::Object
            p.pointer
          else
            p
          end
        end
      end

      def to_json *args
        %Q|{"__op":"AddRelation","objects":[#{@pointers.map(&:to_json).join(',')}]}|
      end
    end
  end
end
