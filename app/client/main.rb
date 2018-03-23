require 'pp'
require 'rx'
require 'tty'
require 'singleton'
require 'eventmachine'
require_relative '../rpc/rpc.rb'
require_relative './client.rb'
require "curses"


class Session
  attr_reader :conn
  def initialize(conn)
    @conn = conn
  end

  def dispose
  end

  def send_data data
    @conn.send_data data
  end
end

class Connection < EventMachine::Connection
  attr_reader :on_command

  def post_init
    @on_command = Rx::Subject.new
    @buffer = ''
    @parsed = false

    Player.instance.set_session(Session.new(self))
  end

  def receive_data data
    #p ">>>server sent: #{data}"
    @buffer += data
    loop do
      @buffer =~ /\n/
      r = $`
      if r.nil?
        break
      else
        @on_command.on_next JSON.parse(r)
        @buffer.sub!(/^.*\n/, '')
      end
    end
  end

  def unbind
    #puts "A connection has terminated"
    @on_command.on_completed
  end
end

EventMachine.run {
  EventMachine.connect "127.0.0.1", 8081, Connection
}
Curses.close_screen
