module Parse
  class Date < Time
    def to_h
      {
        "__type" => "Date",
        "iso" => strftime('%Y-%m-%dT%H:%M:%SZ')
      }
    end

    def to_json *args
      to_h.to_json
    end

    def to_s
      to_json
    end
  end
end
