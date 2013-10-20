# coding:utf-8
module Parse
  class GeoPoint
    include Util

    attr_accessor :latitude, :longitude

    def initialize hash={}
      hash = string_keyed_hash hash
      @latitude = hash['latitude']
      @longitude = hash['longitude']
    end

    def to_h
      {
        "__type" => "GeoPoint",
        "latitude" => @latitude,
        "longitude" => @longitude
      }
    end

    def to_json *args
      to_h.to_json
    end
  end
end
