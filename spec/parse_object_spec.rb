# coding:utf-8
require 'spec_helper'

# define a parse class
class ClassA < Parse::Object; end
# you can also write:
#   Parse::Object(:ClassA)
# or
#   Parse::Object.create :ClassA

describe Parse::Object, 'when it defines a parse class' do
  it 'should return a new class' do
    Parse::Object(:ClassB).should be_a_kind_of(Class)
    ClassB.should be < Parse::Object
  end

  it 'should return the existing class' do
    Parse::Object(:ClassA).should == ClassA
  end

  it 'should also return a new class' do
    Parse::Object.create :ClassC
    ClassC.should be_a_kind_of(Class)
    ClassC.should be < Parse::Object
  end

  it 'should raise an error when creating an existing class' do
    expect {
      Parse::Object.create :ClassB
    }.to raise_error 
  end
end

describe Parse::Object, 'when it creates a new parse object' do
  a_obj_id = nil
  it 'should create a parse object' do
    VCR.use_cassette 'object_new' do
      class_a = ClassA.new
      class_a.columnA = 'Hello, parse.com'
      class_a.new?.should be_true
      class_a.save
      class_a.new?.should be_false
      a_obj_id = class_a.parse_object_id
    end
  end

  it 'should create a parse object' do
    VCR.use_cassette 'object_find' do
      class_a2 = ClassA.find_by_id a_obj_id
      class_a2.columnA.should eql('Hello, parse.com')

      class_as = ClassA.find :where => proc{column(:columnB).gt 5},
        :order => 'createdAt', :keys => 'columnB', :limit => 3
      class_as.size.should == 3

      class_a = ClassA.find :where => {'objectId' => 'UUqhbnuTYx'},
        :order => 'createdAt', :keys => 'columnB', :limit => 3
      class_a.size.should == 1
    end
  end
end

describe Parse::Object, 'when it updates an existing parse object' do
  it 'should increment a field' do
    VCR.use_cassette 'object_increment' do
      class_a = ClassA.find(:all, :limit =>1).first
      val = class_a.columnB || 0
      class_a.columnB = Parse::Op::Increment.new 1
      class_a.save
      class_a.columnB.should == (val + 1)
    end
  end
end
