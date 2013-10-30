# encoding:utf-8
module Parse
  class ParseFile
    include Util

    attr_accessor :name, :url, :content, :type

    def initialize hash
      hash = string_keyed_hash hash
      @name = hash['name']
      raise 'name is mandatory' unless @name
      @url = hash['url']
      @content = hash['content']
      @type = hash['type'] || {
        '.txt' => 'text/plain',
        '.html' => 'text/html',
        '.jpg' => 'image/jpeg',
        '.jpeg' => 'image/jpeg',
        '.png' => 'image/png',
        '.gif' => 'image/gif'
      }[File.extname(@name).downcase]
      @client = hash['parce_client'] || Parse::Client.default
    end

    def save
      raise "Files cannot be updated." if @url
      if @type =~ %r|^image/|
        @content = @content.respond_to?(:read) ? @content.read : File.read(@content)
      end
      @client.call_api :post, "files/#{@name}", @content, 'Content-Type' => @type, 'Accept' => nil do |resp_body|
        @name = resp_body['name']
        @url = resp_body['url']
      end
    end

    def delete!
      raise "File should be fetched" unless @url
      @client.use_master_key do
        @client.call_api :delete, "files/#{@name}", nil, 'Content-Type' => nil, 'Accept' => nil
      end
    end

    def load &block
      open @url do |content| @content = content.read end unless @content
      block.call @content if block
      @content
    end

    def store filepath=nil
      filepath ||= @name
      raise 'filepath is mandatory' unless filepath

      FileUtils.mkdir_p File.dirname(filepath)
      load do |content|
        open filepath, 'wb' do |file|
          file.write content
        end
      end
    end

    def inspect
      content, @content = @content, '..snip..'
      ret = super
      @content = content
      ret
    end

    def to_h
      {
        "__type" => "File",
        "name" => @name
      }
    end

    def to_json *args
      to_h.to_json
    end
  end
end
