RSpec.configure do |config|
  config.before do
    BarkingDog.resources.root_event_path = "barking-dog"
  end
end
