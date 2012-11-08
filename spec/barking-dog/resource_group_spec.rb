require 'spec_helper'

describe BarkingDog::ResourceGroup do

  before do
    @resource_group = BarkingDog::ResourceGroup.new("TestGroup")
  end

  after do
    @resource_group.terminate if @resource_group
  end

  it "should have a name" do
    @resource_group.name.should == "TestGroup"
  end

  it "should stop" do
    @resource_group.stopped.should be_false
    @resource_group.stop
    @resource_group.stopped.should be_true
  end

  describe "#checks" do
    before do
      @check = BarkingDog::Check.new("default")
    end

    it "should add checks" do
      @resource_group.add_check(@check, {cool: true})
      @resource_group.checks[@check].should == {cool: true}
    end

    it "should remove checks" do
      @resource_group.add_check(@check)
      @resource_group.checks.keys.length.should == 1
      @resource_group.remove_check(@check)
      @resource_group.checks.should be_empty
    end

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
          resources: {
              coke_one: {
                foo: 'bar'
              },
              coke_two: {
                foo: 'baz'
              }
          }
      }
    end

    describe "checks" do
      before(:all) do
        class NothingCheck < BarkingDog::Check
          def do_check
            BarkingDog::Event.new({
                state: :healthy,
            })
          end
        end
      end

      before do
        @config[:checks] = [:nothing_check]
      end

      it "should figure out check class from symbol" do
        @resource_group = BarkingDog::ResourceGroup.new("checks", @config)
        @resource_group.checks.keys.first.should == NothingCheck
      end

      it "should use an actual class" do
        @config[:checks] = [NothingCheck]
        @resource_group = BarkingDog::ResourceGroup.new("checks", @config)
        @resource_group.checks.keys.first.should == NothingCheck
      end

      it "should use a hash to pass options" do
        @config[:checks] = [{:name => :nothing_check, :options => {cool: true}}]
        @resource_group = BarkingDog::ResourceGroup.new("checks", @config)
        @resource_group.checks[NothingCheck].should == {cool: true}
      end

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

    describe "with custom classes" do
      before(:all) do
        class Coke < BarkingDog::Resource; end
        class CustomResourceGroup < BarkingDog::ResourceGroup
          self.resource_class = Coke
        end
      end

      before do
        @resource_group = CustomResourceGroup.new("customResourceGroup", @config)
      end

      it "should make resources of the custom class" do
        @resource_group.resources.first.should be_a(Coke)
      end

    end


  end



end
