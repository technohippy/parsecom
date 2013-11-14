# coding:utf-8
require "parse/version"

require 'open-uri'
require 'fileutils'
require 'json'
require 'date'
require 'net/https'
require 'uri'
require 'parse/ext/string'
require 'parse/util'
require 'parse/http_client'
require 'parse/client'
require 'parse/query'
require 'parse/acl'
require 'parse/object'
require 'parse/user'
require 'parse/role'
require 'parse/installation'
require 'parse/geo_point'
require 'parse/pointer'
require 'parse/relation'
require 'parse/file'
require 'parse/date'
require 'parse/op/increment'
require 'parse/op/add'
require 'parse/op/add_unique'
require 'parse/op/remove'
require 'parse/op/add_relation'
require 'parse/op/remove_relation'
require 'parse/op/delete'
require 'parse/batch'
require 'parse/batch_http_client'
require 'parse/event'
require 'parse/event/app_opened'
require 'parse/event/error'

module Parse
  @@application_id = ENV['PARSE_APPLICATION_ID']
  @@api_key = ENV['PARSE_API_KEY']
  @@master_key = ENV['PARSE_MASTER_KEY']
  @@auto_snake_case = false

  module_function

  def application_id
    @@application_id
  end

  def application_id= application_id
    @@application_id = application_id
  end

  def api_key
    @@api_key
  end

  def api_key= api_key
    @@api_key = api_key
  end

  def master_key
    @@master_key
  end

  def master_key= master_key
    @@master_key = master_key
  end

  def credentials hash
    @@application_id = hash[:application_id]
    @@api_key = hash[:api_key]
    @@master_key = hash[:master_key]
  end

  def credentials= hash
    credentials hash
  end

  def auto_snake_case
    @@auto_snake_case
  end

  def auto_snake_case= auto_snake_case
    @@auto_snake_case = auto_snake_case
  end

  def use_master_key!
    Parse::Client.default.use_master_key!
  end
end
