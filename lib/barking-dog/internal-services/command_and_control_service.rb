module BarkingDog
  class CommandAndControlService < BaseService
    include Celluloid::ZMQ

    attr_reader :socket, :address
    def initialize
      subscribe("barking-dog.new_configuration_saved", :handle_new_configuration_saved)
      @address = if config_service = Actor[:configuration_service] and config_service.alive?
                   Actor[:configuration_service].configuration[:command_and_control_address]
                 else
                   DEFAULT_COMMAND_AND_CONTROL_SOCKET
                 end
      setup_socket
      run
    end

    def dispatch_command(command, *args)
      case command
        when "stop"
          publish("barking-dog.termination_request", :command_control_term)
        when "reload"
          publish("barking-dog.reload_request", args.first)
        else
          logger.error("unkown command: '#{command}' with args: #{args.inspect}")
      end
    end

    def handle_new_configuration_saved(pattern, config)
      stop_loop
      @address = config[:command_and_control_address] || DEFAULT_COMMAND_AND_CONTROL_SOCKET
      setup_socket
      run
    end

    def setup_socket
      socket.close if @socket
      @socket = SubSocket.new
      logger.debug("command and control listening to #{address}")
      socket.bind(address)
    end

    def run
      socket.subscribe(COMMAND_AND_CONTROL_TOPIC)
      @listening = true
      async.message_loop
    end

    def terminate
      stop_loop
      super
    end

    def stop_loop
      logger.debug("stopping listening loop")
      @listening = false
    end

    def message_loop
      logger.debug("subscribed to #{COMMAND_AND_CONTROL_TOPIC}")
      while @listening
        handle_socket_message(socket.read)
      end
    end

    def handle_socket_message(socket_message)
      logger.debug("command and control: received message #{message_without_topic(socket_message)}")
      command,*args = message_without_topic(socket_message).split(',')
      dispatch_command(command,*args)
    end

    def message_without_topic(socket_message)
      socket_message.gsub(/^#{COMMAND_AND_CONTROL_TOPIC}\s/, '')
    end

  end
end
