require 'pp'
require 'rx'
require 'tty'
require 'singleton'
require 'eventmachine'
require_relative '../rpc/rpc.rb'
require_relative './view.rb'
require_relative './fellow.rb'
require "curses"

class Client
  def self.set_player_class klass
    @@player_klass = klass
  end

  attr_reader :player
  attr_reader :fellows
  attr_reader :raid

  def view
    View.instance
  end

  def initialize
    @player = nil
    @fellows = {}
    @raid = {x: 0, y: 0, hp: 0}
  end

  def update
    @player.update
  end

  def start_gameloop
    @disposable = Rx::Observable.timer(1, 0.1)
      .time_interval
      .pluck('interval')
      .subscribe(
        lambda {|x| update },
        lambda {|err| raise err.to_s },
        lambda { puts 'Completed' })
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

    @player_id = view.login_prompt

    view.login
    send_data Login.new(@player_id)
  end

  def init_input
    # UI thread
    Thread.new do
      while true
        Thread.pass    # メインスレッドが確実にjoinするように
        c = Curses.getch
        x, y = @player.x, @player.y
        case c
        when 'a'
          send_data Move.new(x-1, y)
        when 'd'
          send_data Move.new(x+1, y)
        when 'w'
          send_data Move.new(x, y-1)
        when 's'
          send_data Move.new(x, y+1)
        when ' '
          send_data Attack.new(@player.x, @player.y)
          send_data Attack.new(@raid['x'], @raid['y'])
        end
      end
    end
  end

  def send_data data
    @session.send_data data.to_json + "\n"
  end

  # RPC

  def loggedin(params)
    @player = @@player_klass.new self, @player_id, params['x'], params['y']
    view.loggedin self
    view.init_game
    start_gameloop
    init_input
  end

  def left(params)
    name = params['name']
    @fellows.delete name
  end

  def moved(params)
    name = params['name']
    x = params['x']
    y = params['y']

    raise if name.nil?

    if name == @player_id
      @player.setpos x, y
    end

    unless @fellows.key? name
      @fellows[name] = Fellow.new name, x, y
    else
      @fellows[name].setpos x, y
    end
  end

  def raid_moved(params)
    x = params['x']
    y = params['y']
    @raid['x'] = x
    @raid['y'] = y
  end

  def sync(params)
    users = params['users']
    @raid = params['raid']
    users.each do |user|
      moved(user)
    end
    start_gameloop
  end

  def attacked(params)
    view.add_attack_effect(params['x'], params['y'])
    @raid['hp'] = params['raid_hp']
  end
end
