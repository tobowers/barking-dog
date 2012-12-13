module BarkingDog
  class CommandAndControlService
    include BarkingDog::BasicService
    include Celluloid::ZMQ

    self.internal_root_path = ''
    on("new_configuration.saved", :handle_new_configuration_saved)

    attr_reader :socket, :address
    def initialize
      @address = if config_service = Actor[:configuration_service] and config_service.alive?
                   Actor[:configuration_service].configuration[:command_and_control_address]
                 else
                   DEFAULT_COMMAND_AND_CONTROL_SOCKET
                 end
      setup_socket
    end

    def dispatch_command(command, *args)
      case command
        when "stop"
          root_trigger("termination_request", payload: :command_control_term)
        when "reload"
          root_trigger("reload_request", payload: args.first)
        else
          logger.error("unkown command: '#{command}' with args: #{args.inspect}")
      end
    end

    def handle_new_configuration_saved(pattern, event)
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
      socket.subscribe(COMMAND_AND_CONTROL_TOPIC)
    end

    def run
      @listening = true
      message_loop
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
      logger.debug("stopped message loop on #{COMMAND_AND_CONTROL_TOPIC}")
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
