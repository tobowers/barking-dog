require 'spec_helper'

describe BarkingDog::ResourceGroup do

  before do
    @resource_group = BarkingDog::ResourceGroup.new("TestGroup")
  end

  it "should have a name" do
    @resource_group.name.should == "TestGroup"
  end

  describe "#resources" do
    before do
      @resource1 = BarkingDog::Resource.new("one")
      @resource2 = BarkingDog::Resource.new("two")
      @resource_group.resources.empty?.should be_true
    end

    it "should accept resources" do
      @resource_group.add_resources([@resource1, @resource2])
      @resource_group.resources.should include(@resource1)
      @resource_group.resources.should include(@resource2)
    end

    it "should remove resources" do
      @resource_group.add_resources([@resource1, @resource2])
      @resource_group.remove_resource(@resource2)
      @resource_group.resources.should include(@resource1)
      @resource_group.resources.should_not include(@resource2)
    end
  end

  describe "configuration" do
    before do
      @config = {
          coke_one: {
            foo: 'bar'
          },
          coke_two: {
            foo: 'baz'
          }
      }
    end

    describe "with default classes" do
      before do
        @resource_group = BarkingDog::ResourceGroup.new("cokes", @config)
      end

      it "should create resources" do
        resource = @resource_group.resources.first
        resource.name.should == :coke_one
        resource.options.foo.should == 'bar'

        resource = @resource_group.resources.last
        resource.name.should == :coke_two
        resource.options.foo = 'baz'

      end



    end


  end



end
