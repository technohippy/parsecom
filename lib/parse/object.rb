# coding:utf-8
module Parse
  RESERVED_PARSE_CLASS = {
    '_User' => 'Parse::User',
    '_Role' => 'Parse::Role',
    '_Installation' => 'Parse::Installation'
  }

  class Object
    @@parse_class_vs_class_table = {}

    class << self
      attr_accessor :parse_class_name, :parse_client, :auto_camel_case

      def register_parse_class parse_class
        @@parse_class_vs_class_table[parse_class.parse_class_name] = parse_class
      end

      def create parse_class_name, mod=::Object
        raise 'already defined' if mod.const_defined? parse_class_name

        if RESERVED_PARSE_CLASS.has_key? parse_class_name.to_s
          eval RESERVED_PARSE_CLASS[parse_class_name.to_s]
        else
          klass = Class.new(Parse::Object)
          klass.parse_class_name = parse_class_name.to_sym
          klass.auto_camel_case = true
          mod.const_set parse_class_name, klass
          register_parse_class klass
        end
      end

      def parse_class_name
        @parse_class_name ||= name.split('::').last
      end

      def parse_client
        @parse_client ||= Parse::Client.default
      end

      def find object_id_or_conditions, opts={}
        results = [parse_client.find(self.parse_class_name, object_id_or_conditions, opts)].flatten
        results.map! {|hash| self.new hash}
      end

      def find_by_id object_id, opts={}
        find(object_id, opts).first
      end

      # TODO: need refactoring
      def find! object_id_or_conditions, opts={}
        results = [parse_client.find!(self.parse_class_name, object_id_or_conditions, opts)].flatten
        results.map! {|hash| self.new hash}
      end

      def find_by_id! object_id, opts={}
        find!(object_id, opts).first
      end

      def find_all opts={}
        find :all, opts
      end

      def find_all! opts={}
        find! :all, opts
      end
    end

    attr_accessor :parse_object_id, :created_at, :updated_at, :acl

    def initialize hash={}
      body_hash = nil
      hash = string_keyed_hash hash
      if hash.has_key? 'objectId'
        @parse_object_id = hash['objectId']
        @raw_hash = hash
        @updated_hash = {}
        body_hash = @raw_hash
      else
        @raw_hash = {}
        @updated_hash = hash
        body_hash = @updated_hash
      end
      @deleted = false

      hash.each do |k, v|
        if v.is_a? Hash
          body_hash[k] = 
            case v['__type']
            when 'Date'
              Date.parse v['iso']
            when 'File'
              Parse::File.new v
            when 'Pointer'
              Parse::Pointer.new v, self
            when 'Relation'
              Parse::Relation.new self, k, v
            else
              v
            end
        end
      end
    end

    def new?
      !@deleted && @raw_hash.empty?
    end

    def updated?
      !@deleted && !@updated_hash.empty?
    end

    def deleted?
      @deleted
    end

    def parse_client
      self.class.parse_client
    end

    def parse_class_name
      self.class.parse_class_name
    end

    def save hash=@updated_hash, use_master_key=false
      check_deleted!

      unless hash.is_a? Hash
        hash = @updated_hash
        use_master_key = hash 
      end
      hash = string_keyed_hash hash
      if new?
        create hash, use_master_key
      else
        update hash, use_master_key
      end
    end

    def save! hash=@updated_hash
      save hash, true
    end

    def create hash, use_master_key=false
      check_deleted!
      hash = string_keyed_hash hash
      @updated_hash.update hash
      method = use_master_key ? :create! : :create
      parse_client.send(method, self.parse_class_name, @updated_hash).tap do |response|
        @parse_object_id = response['objectId']
        @created_at = Date.parse response['createdAt']
        @updated_at = @created_at
        @raw_hash.update @updated_hash
        @raw_hash.update response
        @updated_hash.clear
      end
    end
    
    def create! hash
      create hash, true
    end

    def update hash, use_master_key=false
      check_deleted!
      hash = string_keyed_hash hash
      method = use_master_key ? :update! : :update
      parse_client.send(method, parse_class_name, parse_object_id, hash).tap do |response|
        @raw_hash.update @updated_hash
        @raw_hash.update response
        @updated_at = Date.parse response['updatedAt']
        @updated_hash.clear
      end
    end

    def update! hash
      update hash, true
    end

    def delete use_master_key=false
      raise 'You cannot delete new object' if new?
      check_deleted!
      method = use_master_key ? :delete! : :delete
      parse_client.send(method, parse_class_name, parse_object_id).tap do |response|
        @deleted = true
      end
    end

    def delete!
      delete true
    end

    def parse_object_id
      @parse_object_id || @raw_hash['objectId']
    end

    alias obj_id parse_object_id
    alias obj_id= parse_object_id=

    def get_column name
      name = name.to_s
      ret = @updated_hash[name]
      if ret.nil? && self.class.auto_camel_case
        ret = @updated_hash[name.camelize :lower]
      end
      if ret.nil?
        ret = @raw_hash[name]
        if ret.nil? && self.class.auto_camel_case
          ret = @raw_hash[name.camelize :lower]
        end
      end
      ret
    end

    def set_column name, value
      check_deleted!
      @updated_hash[name] = value
    end

    def pointer
      Pointer.new 'className' => parse_class_name, 'objectId' => parse_object_id
    end

    def to_s
      "<#{parse_class_name}: #{{}.update(@raw_hash).update(@updated_hash).to_s}>"
    end

    def method_missing name, *args, &block
      if name =~ /^\w+$/ && args.empty? && block.nil?
        get_column name
      elsif name[-1] == '=' && args.size == 1 && block.nil?
        set_column name[0..-2], args.first
      else
        super
      end
    end

    private

    def string_keyed_hash hash
      new_hash = {}
      hash.each do |k, v|
        new_hash[k.to_s] = v
      end
      new_hash
    end

    def check_deleted!
      raise 'This object has already been deleted.' if deleted?
    end
  end

  #
  # create or get ParseObject class in the given module
  #
  # == Parameters:
  # parse_class_name::
  #   Parse class name
  # mod::
  #   module where ParseObject is populated
  #
  # == Returns:
  # subclass of ParseObject for the given parse_class_name
  #
  def self.Object parse_class_name, mod=::Object
    if RESERVED_PARSE_CLASS.has_key? parse_class_name.to_s
      eval RESERVED_PARSE_CLASS[parse_class_name.to_s]
    else
      Parse::Object.create parse_class_name, mod \
        unless mod.const_defined? parse_class_name
      mod.const_get parse_class_name
    end
  end
end
