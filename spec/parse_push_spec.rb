# coding:utf-8
require 'spec_helper'
require 'parsecom'

describe Parse::Push, 'when push' do
  it 'should send a simple push message' do
    push = Parse::Push.new
    push.channels = ['Giants', 'Mets']
    push.data = 'The Giants won against the Mets 2-3.'
    push.to_json.should == '{"channels":["Giants","Mets"],"data":{"alert":"The Giants won against the Mets 2-3."}}'
  end

  it 'should send a conditional push message' do
    push = Parse::Push.new
    push.where 'injuryReports' => true
    push.data = 'Willie Hayes injured by own pop fly.'
    push.to_json.should == '{"where":{"injuryReports":true},"data":{"alert":"Willie Hayes injured by own pop fly."}}'

    push = Parse::Push.new
    push.where 'channels' => 'Giants', 'scores' => true
    push.data = 'The Giants scored a run! The score is now 2-2.'
    push.to_json.should == '{"where":{"channels":"Giants","scores":true},"data":{"alert":"The Giants scored a run! The score is now 2-2."}}'
=begin
TODO:
curl -X POST \
  -H "X-Parse-Application-Id: " \
  -H "X-Parse-REST-API-Key: " \
  -H "Content-Type: application/json" \
  -d '{
    "where": {
      "user": {
        "$inQuery": {
          "location": {
            "$nearSphere": {
              "__type": "GeoPoint",
              "longitude": -20.0
            },
            "$maxDistanceInMiles": 1.0
          }
        }
      }
    },
    "data": {
      "alert": "Free hotdogs at the Parse concession stand!"
    }
  }' \
  https://api.parse.com/1/push
=end
  end
  
#  it 'should send a customized push message' do
#  end
  
#  it 'should send a push message with expiration date' do
#  end
  
#  it 'should send a push message with target' do
#  end

  it 'should send a schedued push message' do
    push = Parse::Push.new
    push.where 'user_id' => 'user_123'
    push.at Time.new(2014, 12, 3, 21, 0, 0, '+09:00')
    push.data = 'You previously created a reminder for the game today'
    push.to_json.should == '{"where":{"user_id":"user_123"},"push_time":"2014-12-03T12:00:00Z","data":{"alert":"You previously created a reminder for the game today"}}'
  end
end
