require 'rx'
require_relative "./server.rb"

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
    @last_attacked = Time.now
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

    @connection.send Loggedin.new(true, @x, @y)
    @connection.send Sync.new(Server.instance.active_users.map{|player| player.to_hash}, Server.instance.raid.to_hash)
    @connection.broadcast Moved.new(@name, @x, @y)
  end

  def move(params)
    p "[Server] @#{@name} move required with #{params}"

    x = params['x']
    y = params['y']

    if Server.instance.can_move? self, x, y
      @x = x
      @y = y
      @connection.broadcast Moved.new(@name, @x, @y)
    end
  end

  def attack(params)
    p "[Server] @#{@name} attack with #{params}"
    raid = Server.instance.raid
    return if (Time.now - @last_attacked) < 0.2
    r = 1
    x = params['x']
    y = params['y']
    x = @x
    y = @y
    if (x-r..x+r).include?(raid.x) && (y-r..y+r).include?(raid.y)
      raid.attacked(1)
    end
    @connection.broadcast Attacked.new(x, y, raid.hp)
    @last_attacked = Time.now
  end
end
