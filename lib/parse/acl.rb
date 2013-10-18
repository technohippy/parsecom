# coding:utf-8
module Parse
  class ACL
    READ_ONLY = {'read' => true}
    WRITE_ONLY = {'write' => true}
    READ_WRITE = {'read' => true, 'write' => true}
    NONE = {}
    PUBLIC = '*'

    def initialize hash={}, &block
      @acl = hash.dup
      tap &block if block
    end

    def readable user
      (@acl[user] ||= {})['read'] = true
    end

    def readable? user
      !!(@acl[user] ||= {})['read']
    end

    def writable user
      (@acl[user] ||= {})['write'] = true
    end

    def writable? user
      !!(@acl[user] ||= {})['write']
    end

    def to_json *args
      @acl.to_json
    end

    PUBLIC_READ_ONLY = self.new PUBLIC => READ_ONLY
    PUBLIC_WRITE_ONLY = self.new PUBLIC => WRITE_ONLY
    PUBLIC_READ_WRITE = self.new PUBLIC => READ_WRITE
    PUBLIC_NONE = self.new PUBLIC => NONE
  end
end
