# coding:utf-8
module Parse
  class Object
    class << self
      attr_accessor :parse_class_name, :parse_client, :auto_camel_case

      def create parse_class_name, mod=::Object
        raise 'already defined' if mod.const_defined? parse_class_name

        klass = Class.new(Parse::Object)
        klass.parse_class_name = parse_class_name.to_sym
        klass.auto_camel_case = true
        mod.const_set parse_class_name, klass
      end

      def parse_class_name
        @parse_class_name || name.split('::').last
      end

      def parse_client
        @parse_client ||= Parse::Client.default_client
      end

      def find object_id_or_conditions, opts={}
        parse_client.find self, object_id_or_conditions, opts
      end
    end

    attr_accessor :obj_id, :created_at, :updated_at, :acl

    def initialize hash={}
      hash = string_keyed_hash hash
      if hash.has_key? 'objectId'
        @obj_id = hash['objectId']
        @raw_hash = hash
        @updated_hash = {}
      else
        @raw_hash = {}
        @updated_hash = hash
      end
      @deleted = false
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

    def save hash=@updated_hash
      check_deleted!
      hash = string_keyed_hash hash
      if new?
        create hash
      else
        update hash
      end
    end

    def create hash
      check_deleted!
      hash = string_keyed_hash hash
      @updated_hash.update hash
      parse_client.create(self, @updated_hash).tap do |response|
        @obj_id = response['objectId']
        @created_at = Date.parse response['createdAt']
        @updated_at = @created_at
        @raw_hash.update @updated_hash
        @raw_hash.update response
        @updated_hash.clear
      end
    end

    def update hash
      check_deleted!
      hash = string_keyed_hash hash
      parse_client.update(self, hash).tap do |response|
        @updated_at = Date.parse response['updatedAt']
        @raw_hash.update @updated_hash
        @updated_hash.clear
      end
    end

    def delete
      raise 'You cannot delete new object' if new?
      check_deleted!
      parse_client.delete(self).tap do |response|
        @deleted = true
      end
    end

    def obj_id
      @obj_id || @raw_hash['objectId']
    end

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
    Parse::Object.create parse_class_name, mod \
      unless mod.const_defined? parse_class_name
    mod.const_get parse_class_name
  end
end
