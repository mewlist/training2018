
class Raid
  attr_reader :x, :y
  attr_reader :hp

  def initialize(x, y, hp)
    @hp = hp
    @x, @y = x, y
  end

  def setpos(x, y)
    @x, @y = x, y
  end

  def sethp(hp)
    @hp = hp
  end
end
