require 'spec_helper'

describe BarkingDog do

  # sort of round about way to test that the setting and getting works without
  # modifying a global
  it "should have resources" do
    BarkingDog.resources.comand_and_control_topic.should be_a(String)
  end

end
