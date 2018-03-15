require 'pp'
require 'rx'
require 'tty'
require 'singleton'
require 'eventmachine'
require_relative '../rpc/rpc.rb'
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

class Player
  include Singleton

  def initialize
    @state = nil
    @active = false
    @raid = nil
    @fellows = {}
  end

  def set_session(session)
    @command_disposable.dispose unless @command_disposable.nil?
    @session = session
    @command_disposable = @session.conn.on_command.as_observable
      .subscribe(
        lambda {|x|
          # invoke rpc method
          self.method(x['func']).call(x['params'])
        },
        lambda {|err| puts 'Error: ' + err.to_s },
        lambda { puts 'Completed' })

    @name = TTY::Prompt.new.ask("What's your name?", required: true)

    puts 'Login to server'
    @bar = TTY::ProgressBar.new("Login [:bar]", total: 100)
    90.times do
      sleep 0.01
      @bar.advance(1)
    end
    @session.send_data Login.new(@name).to_json + "\n"
  end

  def loggedin(params)
    @bar.advance(10)
    puts 'Login Succeeded !'
    sleep 1
    game
  end

  def left(params)
    name = params['name']
    @fellows.delete name
    update_screen
  end

  def moved(params)
    name = params['name']
    x = params['x']
    y = params['y']
    if name == @name
      @x = x
      @y = y
    end
    raise if name.nil?
    @fellows[name] = {'x' => x, 'y' => y}
    update_screen
  end

  def raid_moved(params)
    x = params['x']
    y = params['y']
    @raid['x'] = x
    @raid['y'] = y
    update_screen
  end

  def sync(params)
    pp params
    users = params['users']
    @raid = params['raid']
    users.each do |user|
      moved(user)
    end
  end

  def game
    @x = 0
    @y = 0

    Curses.init_screen
    begin
      Curses.crmode
      Curses.noecho
      Curses.setpos((Curses.lines - 1) / 2, (Curses.cols - 11) / 2)
      Curses.addstr("Hit any key")
      Curses.setpos(5, 1)
      Curses.addstr("Hit any key")
      Curses.addstr("Hit any key")
      Curses.refresh
    ensure
    end

    # UI thread
    Thread.new do
      while true
        Thread.pass    # メインスレッドが確実にjoinするように
        c = Curses.getch
        case c
        when 'a'
          @x -= 1
        when 'd'
          @x += 1
        when 'w'
          @y -= 1
        when 's'
          @y += 1
        end
        @x = [[@x, 0].max, 40].min
        @y = [[@y, 0].max, 40].min
        update_screen
        @session.send_data Move.new(@x, @y).to_json + "\n"
      end
    end
#    command = TTY::Prompt.new.select(prompt) do |menu|
#      menu.choice 'Attack'
#      menu.choice 'Heal'
#      menu.choice 'Defence'
#    end
  end

  def update_screen
    Curses.clear
    @fellows.each do |v|
      pos = v[1]
      name = v[0]
      Curses.setpos(pos['y'], pos['x'])
      if name != @name
        Curses.addstr("+")
      else
        Curses.addstr("@")
      end
    end
    Curses.setpos(@raid['y'], @raid['x'])
    Curses.addstr("#")
    Curses.refresh
  end

  def prompt
    "\n" +
    "========================================\n" +
    "= HP 100/100\n" +
    "= \n" +
    "========================================\n" +
    "Command?"
  end
end

EventMachine.run {
  EventMachine.connect "127.0.0.1", 8081, Connection
}
Curses.close_screen
