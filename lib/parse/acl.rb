# coding:utf-8
module Parse
  class ACL
    def initialize hash={}
      @acl = hash.dup
    end

    def to_json *args
      @acl.to_json
    end
  end
end
