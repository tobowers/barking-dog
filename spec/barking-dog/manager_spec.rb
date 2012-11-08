require 'spec_helper'

describe BarkingDog::Manager do

  before(:all) do
    @config = {
        groups: {
            coke_cans: {
                resources: {
                    coke_one: {
                      config_key: "config_value"
                    }
                },
                checks: [
                    :is_environment_variable_set
                ]
            }
        }
    }

    class CokeCan < BarkingDog::Resource
    end

    class CokeCans < BarkingDog::ResourceGroup
      self.resource_class = CokeCan
    end

    class IsEnvironmentVariableSet < BarkingDog::Check
      def do_check
        if ENV['dofuckup']
          BarkingDog::Event.new({
              state: :unhealthy,
              message: "you fucked up"
          })
        else
          BarkingDog::Event.new({
              state: :healthy,
          })
        end
      end
    end
  end

  before do
    @manager = BarkingDog::Manager.new(@config)
  end

  after do
    @manager.stop
    @manager.terminate
  end

  it "should setup the resource groups" do
    @manager.resource_groups[:coke_cans].should be_a(CokeCans)
  end






end
