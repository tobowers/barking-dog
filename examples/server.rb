$:.push File.expand_path('../../lib', __FILE__)
require 'barking-dog'

class Duck
  include Celluloid

  def quack
    puts "Quack!"
  end
end

Duck.supervise_as :duck_actor

DCell.start :id => "node1", :addr => "tcp://127.0.0.1:4000"

sleep
