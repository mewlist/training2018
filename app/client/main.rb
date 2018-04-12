require 'eventmachine'
require_relative './connection.rb'
require_relative './player.rb'
require_relative './bot.rb'

$ip = ARGV[0] || "127.0.0.1"

Client.set_player_class Bot
EventMachine.run {
  EventMachine.connect $ip, 8081, Connection
}
Curses.close_screen
