# encoding:utf-8
module Parse
  class File
    attr_accessor :name, :url

    def initialize hash
      @raw_hash = hash
      @name = hash['name']
      @url = hash['url']
    end

    def load &block
      open @url do |data| @data = data.read end unless @data
      block.call @data
    end

    def store filepath=nil
      filepath ||= @name
      raise 'filepath is mandatory' unless filepath

      FileUtils.mkdir_p ::File.dirname(filepath)
      load do |data|
        open filepath, 'wb' do |file|
          file.write data
        end
      end
    end

    def inspect
      data, @data = @data, '..snip..'
      ret = super
      @data = data
      ret
    end
  end
end
