# coding:utf-8
require 'spec_helper'
require 'parsecom'

describe Parse::ParseDate, 'when converting from and to json' do
  it 'should be converted to a correct json' do
    date = Parse::ParseDate.parse '2013-10-18T20:53:25Z'
    date.year.should == 2013
    date.month.should == 10
    date.to_json.should == '{"__type":"Date","iso":"2013-10-18T20:53:25Z"}'
  end

  it 'should be converted to a correct json' do
    date = Parse::ParseDate.parse 2013, 10, 18, 20, 53, 25
    date.year.should == 2013
    date.month.should == 10
    date.to_json.should == '{"__type":"Date","iso":"2013-10-18T20:53:25Z"}'
  end

  it 'should be converted from a json' do
    date = Parse::ParseDate.new :iso => '2013-10-18T20:53:25Z'
    date.year.should == 2013
    date.month.should == 10
  end
end
