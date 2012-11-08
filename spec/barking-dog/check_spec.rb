require 'spec_helper'

describe BarkingDog::Check do

  before do
    @resource = BarkingDog::Resource.new("test")
    @check = BarkingDog::Check.new(@resource, {cool: true})
  end

  after do
    @resource.terminate
    @check.terminate
  end

  it "should #resource" do
    @check.resource.should == @resource
  end

  it "should Hashie::Mash the configuration" do
    @check.configuration.cool.should == true
  end

  describe "subclasses" do
    before(:all) do
      class MyPassingCheck < BarkingDog::Check
        def do_check
          [true, {foo: 'bar'}]
        end
      end

      class MyFailingCheck < BarkingDog::Check
        def do_check
          [false, {some_response: true}]
        end
      end
    end

    before do
      #terminate the original one from the top of the file
      @check.terminate
    end

    describe "the event hash returned" do
      before do
        @check = MyPassingCheck.new(@resource)
        @event = @check.do_check_with_event_return
      end

      it "should set passed" do
        @event.passed.should be_true
      end

      it "should use the return hash" do
        @event.foo.should == 'bar'
      end

      it "should set the checker" do
        @event.checker.should == @check
      end

      it "should set the resource" do
        @event.resource.should == @resource
      end

      it "should set passed to false when the check was false" do
        @check.terminate
        @check = MyFailingCheck.new(@resource)
        event = @check.do_check_with_event_return
        event.passed.should be_false
      end

    end

  end

end
