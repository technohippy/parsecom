# coding:utf-8
require 'spec_helper'

# define a parse class
class ClassA < Parse::Object; end
# you can also write:
#   Parse::Object(:ClassA)
# or
#   Parse::Object.create :ClassA

describe Parse, 'when it defines a parse class' do
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

describe Parse, 'when it creates a new parse object' do
  it 'should create a parse object' do
    class_a = ClassA.new
    class_a.columnA = 'Hello, parse.com'
    class_a.new?.should be_true
    class_a.save
    class_a.new?.should be_false

    class_a2 = ClassA.find class_a.obj_id
    class_a2.columnA.should eql('Hello, parse.com')

    class_as = ClassA.find :where => proc{column(:columnB).gt 5},
      :order => 'createdAt', :keys => 'columnB', :limit => 3
    class_as.size.should == 3
  end
end

