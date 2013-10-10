# coding:utf-8
require 'spec_helper'
require 'parsecom'

describe Parse::Client, 'when using master_key' do
  it 'should use api key' do
    client = Parse::Client.new
    client.build_headers.keys.should be_include('X-Parse-REST-API-Key')
    client.build_headers.keys.should_not be_include('X-Parse-Master-Key')
  end

  it 'should use master key' do
    client = Parse::Client.new
    client.use_master_key!
    client.build_headers.keys.should_not be_include('X-Parse-REST-API-Key')
    client.build_headers.keys.should be_include('X-Parse-Master-Key')
  end

  it 'should raise an error when master_key is not set' do
    client = Parse::Client.new
    client.master_key = nil
    expect {
      client.use_master_key!
    }.to raise_error
  end
end
