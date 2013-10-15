# coding:utf-8
require 'spec_helper'
require 'parsecom'

describe Parse::Batch, 'when executing a batch request' do
  it 'should be success' do
    VCR.use_cassette 'batch' do
      a1 = ClassA.new 'columnA' => 'hello'
      a2 = ClassA.new 'columnA' => 'world'
      a3 = ClassA.find(:all, :limit =>1).first
      a3.columnA = 'updated!'
      a3_updated_at = a3.updatedAt
      batch = Parse::Batch.new
      batch.add_request do
        a1.save
        a2.save
        a3.save
      end
      batch.run
      a1.parse_object_id.should_not be_nil
      a2.parse_object_id.should_not be_nil
      a3.columnA.should == 'updated!'
      a3.updatedAt.should_not == a3_updated_at
    end
  end
end
