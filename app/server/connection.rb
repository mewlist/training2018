class Connection < EventMachine::Connection
  TERMINATOR = "\n"

  attr_reader :on_call

  def post_init
    puts "-- someone connected to the server!"
    @stream = CommandStream.new
    @on_call = Rx::Subject.new
    @stream.on_call
      .as_observable
      .subscribe(
        -> v { @on_call.on_next v },
        -> err { puts 'Error: ' + err.to_s },
        -> { @on_call.on_completed })

    Server.instance.register self
  end

  def receive_data(data)
    # p "received: #{data}"
    @stream.push data
  end

  def unbind
    puts "-- someone disconnected from the echo server!"
    @on_call.on_completed
    @stream.dispose
    Server.instance.release self
  end

  def send(data)
    send_data data.to_json + TERMINATOR
  end

  def broadcast(data)
    Server.instance.broadcast data.to_json + TERMINATOR
  end
end

