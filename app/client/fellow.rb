
class Fellow
  attr_reader :name
  attr_reader :x, :y
  attr_reader :power

  def initialize(name, x, y)
    @name = name
    @power = 1
    @x, @y = x, y
  end

  def setpos(x, y)
    @x, @y = x, y
  end

  def setpower(power)
    @power = power
  end

end
