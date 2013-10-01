# coding:utf-8
require 'spec_helper'

describe Parse::User, 'when it signs up' do
  it 'should create new user' do
    user = Parse::User.sign_up "username#{rand 1000}", 'password'
    user.obj_id.should be_an_instance_of String
    user.parse_client.session_token.should be_an_instance_of String
  end
end

describe Parse::User, 'when it logs in' do
  it 'should get the session token' do
    user = Parse::User.log_in 'username', 'password'
    user.obj_id.should be_an_instance_of String
    user.parse_client.session_token.should be_an_instance_of String
  end
end

describe Parse::User, 'when it logs out' do
  it 'should get the session token' do
  end
end
