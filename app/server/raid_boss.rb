require 'rx'
require_relative "./server.rb"

class RaidBoss
  attr_accessor :hp
  attr_reader :x
  attr_reader :y

  def initialize
    @hp = 1000000
    @x, @y = 20, 20
  end

  def update
    x = [[@x+[-1,0,1].sample, 0].max, 40].min
    y = [[@y+[-1,0,1].sample, 0].max, 40].min
    if Server.instance.can_move? self, x, y
      @x = x
      @y = y
      Server.instance.broadcast RaidMoved.new(@x, @y).to_json + "\n"
    end
  end

  def attacked(damage)
    @hp -= damage
  end

  def to_hash
    {x: @x, y: @y, hp: @hp}
  end

end
