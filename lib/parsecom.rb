# coding:utf-8
require "parse/version"

require 'open-uri'
require 'fileutils'
require 'json'
require 'date'
require 'net/https'
require 'uri'
require 'parse/ext/string'
require 'parse/http_client'
require 'parse/client'
require 'parse/query'
require 'parse/object'
require 'parse/user'
require 'parse/role'
require 'parse/installation'
require 'parse/pointer'
require 'parse/relation'
require 'parse/file'
require 'parse/op/increment'

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
end
