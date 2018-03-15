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
  def initialize(resullt)
    @result = true
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
    @x = x
    @y = y
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
