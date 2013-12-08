module Parse
  module Util
    def string_keyed_hash hash
      new_hash = {}
      (hash || {}).each do |k, v|
        new_hash[k.to_s] = v
      end
      new_hash
    end
  end
end
