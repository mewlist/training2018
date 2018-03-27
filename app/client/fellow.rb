
class Fellow
  attr_reader :name
  attr_reader :x, :y

  def initialize(name, x, y)
    @name = name
    @x, @y = x, y
  end

  def setpos(x, y)
    @x, @y = x, y
  end
end
