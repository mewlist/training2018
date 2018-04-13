require 'pp'
require 'json'
require 'rx'
require 'singleton'
require 'eventmachine'
require_relative '../rpc/rpc.rb'
require_relative './connection.rb'

class Server
  include Singleton

  attr_reader :connections
  attr_reader :raid

  def initialize
    @connections = {}
    @raid = RaidBoss.new
    @disposable = Rx::Observable.timer(3, 1)
      .time_interval
      .pluck('interval')
      .subscribe(
        lambda {|x| update },
        lambda {|err| puts 'Error: ' + err.to_s },
        lambda { puts 'Completed' })
  end

  def register(conn)
    @connections[conn] = Player.new(conn)
    p @connections.length
  end

  def release(conn)
    @connections[conn].dispose
    @connections.delete conn
    p @connections.length
  end

  def broadcast(data)
    active_users.each do |player|
      player.connection.send_data data
    end
  end

  def active_users
    Server.instance.connections.values.select{|v| v.active}
  end

  def update
    @connections.values.each do |player|
      player.update
    end
    @raid.update
  end

  def can_move?(current, x, y)
    pos = active_users.map{|v| [v.x, v.y]}
    pos.push [@raid.x, @raid.y]
    pos.delete_if {|v|
      p v
      v[0] == current.x && v[1] == current.y
    }
    !pos.any? {|v| v[0] == x && v[1] == y}
  end

  def self.run
    EventMachine.run {
      EventMachine.start_server "0.0.0.0", 8081, Connection
    }
  end
end
