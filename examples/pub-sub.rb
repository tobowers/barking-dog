require 'barking-dog'

require 'celluloid/zmq'

class Server
  include Celluloid::ZMQ

  def initialize(address)
    @socket = SubSocket.new

    begin
      @socket.bind(address)
    rescue IOError
      @socket.close
      raise
    end
  end

  def run
    @socket.subscribe("topic")
    loop { handle_message! @socket.read }
  end

  def handle_message(message)
    puts "got message: #{message}"
  end
end

class Client
  include Celluloid::ZMQ

  def initialize(address)
    @socket = PubSocket.new

    begin
      @socket.connect(address)
    rescue IOError
      @socket.close
      raise
    end
  end

  def write(message)
    @socket.send(message)

    nil
  end
end

addr = 'tcp://127.0.0.1:3435'

server = Server.new(addr)
client = Client.new(addr)

server.run!
client.write('topic hi')
