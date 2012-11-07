require 'spec_helper'

describe BarkingDog::Manager do

  before(:all) do
    @config = {
        groups: {
            coke_cans: {
                coke_one: {
                  config_key: "config_value"
                }
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
          Event.new({
              state: :unhealthy,
              message: "you fucked up"
          })
        else
          Event.new({
              state: :healthy,
          })
        end
      end
    end


  end




end
