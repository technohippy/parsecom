module Parse
  module Op
    class Delete
      def to_json *args
        %Q|{"__op":"Delete"}|
      end
    end
  end
end
