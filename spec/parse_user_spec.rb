# coding:utf-8
require 'spec_helper'

describe Parse::User, 'when it signs up' do
  it 'should create new user' do
    VCR.use_cassette 'user_sign_up' do
      user = Parse::User.sign_up "username#{rand 1000}", 'password'
      user.parse_object_id.should be_an_instance_of String
      user.parse_client.session_token.should be_an_instance_of String
    end
  end
end

describe Parse::User, 'when it logs in' do
  it 'should get the session token' do
    VCR.use_cassette 'user_log_in' do
      user = Parse::User.log_in 'username', 'password'
      user.parse_object_id.should be_an_instance_of String
      user.parse_client.session_token.should be_an_instance_of String
    end
  end
end

describe Parse::User, 'when it logs out' do
  it 'should get the session token' do
  end
end

describe Parse::User, 'when it is included in other query' do
  it 'should return a valid User object' do
    VCR.use_cassette 'user_find' do
      class_a = ClassA.find 'UUqhbnuTYx', :include => 'user'
      user = class_a.user
      user.should be_an_instance_of Parse::User
      user.parse_object_id.should == '5VuUwoEe0j'
    end
  end
end
