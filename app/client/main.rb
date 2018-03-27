require 'eventmachine'
require_relative './connection.rb'
require_relative './player.rb'

Client.set_player_class Bot
EventMachine.run {
  EventMachine.connect "127.0.0.1", 8081, Connection
}
Curses.close_screen
