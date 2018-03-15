require 'rx'
require_relative "./server.rb"

class GameState
  def start
  end

  def update
    p 'game state update'
  end

  def execute(command)
    command.Invoke
  end

  def end
  end
end

class RaidBoss
  attr_accessor :hp
  attr_reader :x
  attr_reader :y

  def initialize
    @hp = 1000000
    @x, @y = 20, 20
  end

  def update
    @x = [[@x+[-1,0,1].sample, 0].max, 40].min
    @y = [[@y+[-1,0,1].sample, 0].max, 40].min
    p "raid update"
    Server.instance.broadcast RaidMoved.new(@x, @y).to_json + "\n"
  end

  def to_hash
    {x: @x, y: @y}
  end

end

class Player
  attr_reader :connection

  attr_reader :name
  attr_reader :x
  attr_reader :y

  attr_reader :active
  attr_reader :state

  def initialize(connection)
    @connection = connection
    @state = nil
    @active = false
    @command_disposable = @connection.on_call
      .as_observable
      .subscribe(
        -> v { self.method(v['func']).call(v['params']) },
        -> err { puts 'Error: ' + err.to_s },
        -> { puts 'Player disposed: ' + @name })
  end

  def update
    @state.update unless @state.nil?
  end

  def dispose
    p "player dispose"
    @command_disposable.dispose
    @connection.broadcast Left.new(@name)
  end

  def to_hash
    {name: @name, x: @x, y: @y}
  end

  # RPC implements
  def login(params)
    p "[Server] login required with #{params}"

    @name, @x, @y = params['name'], (0..40).to_a.sample, (0..40).to_a.sample
    @active = true
    @state = GameState.new

    @connection.send Loggedin.new(true)
    @connection.send Sync.new(Server.instance.active_users.map{|player| player.to_hash}, Server.instance.raid.to_hash)
    @connection.broadcast Moved.new(@name, @x, @y)
  end

  def move(params)
    p "[Server] @#{@name} move required with #{params}"

    @x = params['x']
    @y = params['y']

    @connection.broadcast Moved.new(@name, @x, @y)
  end
end

Server.run
