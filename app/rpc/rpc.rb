require 'json'
require_relative './command_stream.rb'

class RPC
end

class ToServer
end

class ToClient
end

class Login < ToServer
  def initialize(name)
    @name = name
  end
  def to_json
    {func: :login, params: {name: @name}}.to_json
  end
end

class Loggedin < ToClient
  def initialize(resullt, x, y)
    @result = true
    @x, @y = x, y
  end
  def to_json
    {func: :loggedin, params: {result: @result}}.to_json
  end
end

class Left < ToClient
  def initialize(name)
    @name = name
  end
  def to_json
    {func: :left, params: {name: @name}}.to_json
  end
end

class Move < ToServer
  def initialize(x, y)
    @x = [[x, 0].max, 40].min
    @y = [[y, 0].max, 40].min
  end
  def to_json
    {func: :move, params: {x: @x, y: @y}}.to_json
  end
end

class Sync < ToClient
  def initialize(users, raid)
    @users = users
    @raid = raid
  end
  def to_json
    {func: :sync, params: {users: @users, raid: @raid}}.to_json
  end
end

class Moved < ToClient
  def initialize(name, x, y)
    @name = name
    @x = x
    @y = y
  end
  def to_json
    {func: :moved, params: {name: @name, x: @x, y: @y}}.to_json
  end
end

class RaidMoved < ToClient
  def initialize(x, y)
    @x = x
    @y = y
  end
  def to_json
    {func: :raid_moved, params: {x: @x, y: @y}}.to_json
  end
end

class Attack < ToServer
  def initialize(x, y)
    @x = x
    @y = y
  end
  def to_json
    {func: :attack, params: {x: @x, y: @y}}.to_json
  end
end

class Attacked < ToClient
  def initialize(x, y, raid_hp)
    @x = x
    @y = y
    @raid_hp = raid_hp
  end
  def to_json
    {func: :attacked, params: {x: @x, y: @y, raid_hp: @raid_hp}}.to_json
  end
end

class Empower < ToServer
  def initialize(x, y)
    @x = x
    @y = y
  end
  def to_json
    {func: :empower, params: {x: @x, y: @y}}.to_json
  end
end

class PowerChanged < ToClient
  def initialize(name, power)
    @name, @power = name, power
  end
  def to_json
    {func: :power_changed, params: {name: @name, power: @power}}.to_json
  end
end
