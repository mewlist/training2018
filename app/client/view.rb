require 'pp'
require 'rx'
require 'tty'
require 'singleton'
require 'eventmachine'
require_relative '../rpc/rpc.rb'
require_relative './effects/attack_effect.rb'
require "curses"

class View
  include Singleton

  def initialize
    @effects = []
  end

  def login_prompt
    TTY::Prompt.new.ask("What's your name?", required: true)
  end

  def login
    puts 'Login to server'
    @bar = TTY::ProgressBar.new("Login [:bar]", total: 100)
    90.times do
      sleep 0.01
      @bar.advance(1)
    end
  end

  def loggedin(client)
    @bar.advance(10)
    @client = client
    puts 'Login Succeeded !'
    sleep 1
  end

  def init_game
    Curses.init_screen
    begin
      Curses.crmode
      Curses.noecho
#      Curses.start_color
      Curses.curs_set(0)
      Curses.refresh
      Curses.init_pair(1, Curses::COLOR_BLUE, Curses::COLOR_BLACK)
    end
    @disposable = Rx::Observable.timer(1, 0.1)
      .time_interval
      .pluck('interval')
      .subscribe(
        lambda {|x| update_screen },
        lambda {|err| raise err.to_s },
        lambda { puts 'Completed' })
  end

  def add_attack_effect(x, y)
    @effects.push AttackEffect.new x, y
  end

  def update_screen
    Curses.clear

    @effects.each do |v|
      v.update
    end
    @effects = @effects.select{|v| !v.disposed}
    @effects.each do |v|
      r = 1
      @debug_message = r
      (v.x-r..v.x+r).each do |x|
        (v.y-r..v.y+r).each do |y|
          Curses.setpos(y, x)
          Curses.addstr(['.',',','+','*','*','|','/','-','.',',','.'][v.t])
        end
      end
    end

    @client.fellows.each do |name, fellow|
      Curses.setpos fellow.y, fellow.x
      if name != @client.player.name
        Curses.addstr("O")
      else
        Curses.attron(Curses.color_pair(1)) do
          Curses.addstr("@")
        end
      end
    end

    @client.fellows.keys.each_with_index do |k, i|
      Curses.setpos(2 + i, 41)
      Curses.addstr('@' + k)
    end
    Curses.setpos(@client.raid['y'], @client.raid['x'])
    Curses.addstr("#")
    Curses.setpos(0, 41)
    Curses.addstr("BOSS HP" + @client.raid['hp'].to_s)
    Curses.setpos(42, 0)
    Curses.addstr(@debug_message.to_s)
    Curses.refresh
  rescue => e
    close e
  end

  def close(e)
    Curses.close_screen
    @disposable.dispose
    p e
  end
end
